function AutomaticUpdates {
    param(
        [switch] $Manual,
        [switch] $Stop
    )
    # 將自動更新設置為手動
    if ($Manual) { 
        if (Test-Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU") {
            reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /f
        }
        (Get-Service -Name:wuauserv)|Set-Service -StartupType:Automatic
        if ((Get-Service -Name:wuauserv).Status -eq "Stopped") { 
            net start wuauserv
            (Get-Service -Name:wuauserv)|Select-Object Name,DisplayName,Status,StartType
        }
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v NoAutoUpdate /t REG_DWORD /d 00000000 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v AUOptions /t REG_DWORD /d 00000002 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v ScheduledInstallDay /t REG_DWORD /d 00000000 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v ScheduledInstallTime /t REG_DWORD /d 00000003 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v ScheduledInstallEveryWeek /t REG_DWORD /d 00000001 /f
        if ($LockVersion) { AutomaticUpdates $LockVersion }
    } 
    # 停用自動更新
    elseif ($Stop) {
        if (Test-Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate") {
            reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f
        }
        # reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v NoAutoUpdate /t REG_DWORD /d 00000001 /f
        if ((Get-Service -Name:wuauserv).Status -eq "Running") { net stop wuauserv }
        (Get-Service -Name:wuauserv)|Set-Service -StartupType:disabled
        (Get-Service -Name:wuauserv)|Select-Object Name,DisplayName,Status,StartType
    }
    # 恢復為未設定狀態
    else { 
        if (Test-Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate") {
            reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f
        }
        (Get-Service -Name:wuauserv)|Set-Service -StartupType:Automatic
        if ((Get-Service -Name:wuauserv).Status -eq "Stopped") { 
            net start wuauserv
            (Get-Service -Name:wuauserv)|Select-Object Name,DisplayName,Status,StartType
        }
    }
} # AutomaticUpdates -Manual

# 鎖定Windows版本
function LockWindowsVersion {
    param (
        [Parameter(Position = 0, ParameterSetName = "Current", Mandatory=$true)]
        [switch]$Current,
        [Parameter(Position = 0, ParameterSetName = "Version", Mandatory=$true)]
        [string]$Version,
        [Parameter(Position = 0, ParameterSetName = "Recovery", Mandatory=$true)]
        [switch]$Unlock
    )
    
    if ($Current) {
        $Systems = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName
        $Version = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
    } elseif ($Version) {
        $Systems = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName
    } elseif ($Unlock) {
        if (Get-ItemProperty -Path "HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name TargetReleaseVersion -ErrorAction SilentlyContinue) {
            reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetReleaseVersion /f
            # reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v ProductVersion /f
            reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetReleaseVersionInfo /f
        }
        Write-Host "已解除 Windows 版本鎖定" -NoNewline
        return
    }
    reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetReleaseVersion /t REG_DWORD /d 00000001 /f
    # reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v ProductVersion /t REG_SZ /d $Systems /f
    reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetReleaseVersionInfo /t REG_SZ /d $Version /f
    Write-Host "已將 Windows 鎖定在 " -NoNewline
    Write-Host "$Systems $Version" -NoNewline -ForegroundColor:Yellow
    Write-Host " 版本"
} # LockWindowsVersion -Current
# LockWindowsVersion -Version:21H2

function Win11_Update {
    param (
        [Parameter(Position = 0, ParameterSetName = "Unlock", Mandatory=$true)]
        [switch]$Unlock,
        [Parameter(Position = 0, ParameterSetName = "Recovery", Mandatory=$true)]
        [switch]$Recovery
    )
    # https://support.microsoft.com/zh-tw/windows/%E5%AE%89%E8%A3%9D-windows-11-%E7%9A%84%E6%96%B9%E6%B3%95-e0edbbfb-cfc5-4011-868b-2ce77ac7c70e
    # https://www.microsoft.com/en-us/software-download/windowsinsiderpreviewpchealth
    if ($Unlock) {
        reg add HKEY_LOCAL_MACHINE\SYSTEM\Setup\MoSetup /v AllowUpgradesWithUnsupportedTPMOrCPU /t REG_DWORD /d 1 /f
        Write-Host "已解除CPU與TPM限制，請直接執行ISO中的安裝檔更新Win11" -ForegroundColor:Yellow
        Write-Host "  注意：無法從 [電腦健康情況檢查] 與 [更新] 中確認或更新，頁面仍會顯示電腦不支援"
        
    } elseif ($Recovery) {
        if (Get-ItemProperty -Path "HKLM:\SYSTEM\Setup\MoSetup" -Name:AllowUpgradesWithUnsupportedTPMOrCPU -ErrorAction SilentlyContinue) {
            reg delete HKEY_LOCAL_MACHINE\SYSTEM\Setup\MoSetup /v AllowUpgradesWithUnsupportedTPMOrCPU /f
        }
        Write-Host "已還原CPU與TPM限制" -ForegroundColor:Yellow
    }
} # Win11_Update -Unlock

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
}
# 鎖定Windows版本
function LockWindowsVersion {
    param (
        [Parameter(Position = 0, ParameterSetName = "Current", Mandatory=$true)]
        [switch]$Current,
        [Parameter(Position = 0, ParameterSetName = "Recovery", Mandatory=$true)]
        [switch]$Unlock
    )
    if ($Current) {
        $Systems = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName
        $Version = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetReleaseVersion /t REG_DWORD /d 00000001 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v ProductVersion /t REG_SZ /d $Systems /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetReleaseVersionInfo /t REG_SZ /d $Version /f
        Write-Host "已將 Windows 鎖定在 " -NoNewline
        Write-Host "$Systems $Version" -NoNewline -ForegroundColor:Yellow
        Write-Host " 版本"
    } elseif ($Unlock) {
        if (Get-ItemProperty -Path "HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name TargetReleaseVersion -ErrorAction SilentlyContinue) {
            reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetReleaseVersion /f
            reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v ProductVersion /f
            reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetReleaseVersionInfo /f
        }
        Write-Host "已解除 Windows 版本鎖定" -NoNewline
    }
} #LockWindowsVersion -Current

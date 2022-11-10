# 刪除空機碼
function Remove-EmptyRegistryKey {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [string] $Key
    )
    $regKey = $Key -replace("^HKEY_","Registry::HKEY_")
    if (Test-Path $regKey) {
        if ((!(Get-ChildItem $regKey) -and !(Get-ItemProperty $regKey))) {
            Remove-Item $regKey
        }
    }
} # Remove-EmptyRegistryKey "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

# 刪除機碼
function Remove-Registry {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [string] $Key,
        [Parameter(Position = 1, ParameterSetName = "")]
        [object] $Name
    )
    $regKey = $Key -replace("^HKEY_","Registry::HKEY_")
    if (Get-ItemProperty -LiteralPath:$regKey $Name) { Remove-ItemProperty -LiteralPath:$regKey $Name }
} 
# reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v AUOptions /t REG_DWORD /d 00000002 /f
# Remove-Registry HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU AUOptions




# 停用自動更新
function StopWinUpdate {
    [CmdletBinding(DefaultParameterSetName = "D")]
    param(
        [Parameter(ParameterSetName = "A")]
        [switch] $Default,
        [Parameter(ParameterSetName = "B")]
        [switch] $Manual,
        [Parameter(ParameterSetName = "B2")]
        [switch] $NotCheck,
        [Parameter(ParameterSetName = "C")]
        [switch] $Stop, # 群組原則恢復預設
        [Parameter(ParameterSetName = "D")]
        [switch] $Help
    )
    # 群組原則對應的機碼位置
    $key1 = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $key2 = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    # 各項功能
    if ($Default) {
        # 群組原則恢復預設
        Remove-Registry $key2 AUOptions -EA:0
        Remove-Registry $key2 NoAutoUpdate -EA:0
        Remove-Registry $key2 ScheduledInstallDay -EA:0
        Remove-Registry $key2 ScheduledInstallEveryWeek -EA:0
        Remove-Registry $key2 ScheduledInstallTime -EA:0
        Remove-EmptyRegistryKey $key2
        Remove-EmptyRegistryKey $key1
        # 啟動服務
        sc.exe config wuauserv start= delayed-auto |Out-Null
        Start-Service wuauserv
        Write-Host "已將更新恢復至預設狀態"
        return
    } elseif ($Manual) {
        # 群組原則設定成手動
        $regKey = $Key2 -replace("^HKEY_","Registry::HKEY_")
        if (!(Test-Path $regKey)) { New-Item $regKey -Force |Out-Null }
        New-ItemProperty $regKey 'AUOptions' -PropertyType:'DWord' -Value '00000002' -EA:0 |Out-Null
        New-ItemProperty $regKey 'NoAutoUpdate' -PropertyType:'DWord' -Value '00000000' -EA:0 |Out-Null
        New-ItemProperty $regKey 'ScheduledInstallDay' -PropertyType:'DWord' -Value '00000000' -EA:0 |Out-Null
        New-ItemProperty $regKey 'ScheduledInstallEveryWeek' -PropertyType:'DWord' -Value '00000001' -EA:0 |Out-Null
        New-ItemProperty $regKey 'ScheduledInstallTime' -PropertyType:'DWord' -Value '00000003' -EA:0 |Out-Null
        # 啟動服務
        sc.exe config wuauserv start= delayed-auto |Out-Null
        Start-Service wuauserv
        Write-Host "已將更新設置為手動 (系統仍然會自動檢查更新並跳出提醒但不會擅自安裝)"
        return
    } elseif ($NotCheck) {
        # 群組原則設定成手動
        $regKey = $Key2 -replace("^HKEY_","Registry::HKEY_")
        if (!(Test-Path $regKey)) { New-Item $regKey -Force |Out-Null }
        New-ItemProperty $regKey 'AUOptions' -PropertyType:'DWord' -Value '00000002' -EA:0 |Out-Null
        New-ItemProperty $regKey 'NoAutoUpdate' -PropertyType:'DWord' -Value '00000000' -EA:0 |Out-Null
        New-ItemProperty $regKey 'ScheduledInstallDay' -PropertyType:'DWord' -Value '00000000' -EA:0 |Out-Null
        New-ItemProperty $regKey 'ScheduledInstallEveryWeek' -PropertyType:'DWord' -Value '00000001' -EA:0 |Out-Null
        New-ItemProperty $regKey 'ScheduledInstallTime' -PropertyType:'DWord' -Value '00000003' -EA:0 |Out-Null
        # 設置服務為手動
        Set-Service wuauserv -StartupType:Manual
        Stop-Service wuauserv
        Write-Host "已將更新設置為不檢查更新 (不會自動檢查更新, 但是手動按下檢查後仍會自動下載並安裝)"
        return
    } elseif ($Stop) {
        # 群組原則恢復預設
        Remove-Registry $key2 AUOptions -EA:0
        Remove-Registry $key2 NoAutoUpdate -EA:0
        Remove-Registry $key2 ScheduledInstallDay -EA:0
        Remove-Registry $key2 ScheduledInstallEveryWeek -EA:0
        Remove-Registry $key2 ScheduledInstallTime -EA:0
        Remove-EmptyRegistryKey $key2
        Remove-EmptyRegistryKey $key1
        # 停用服務
        Set-Service wuauserv -StartupType:Disabled
        Stop-Service wuauserv
        Write-Host "已停用自動更新"
        return
    }
}
# StopWinUpdate -Default
# StopWinUpdate -Manual
# StopWinUpdate -NotCheck
# StopWinUpdate -Stop



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



# 解除升級Win11限制
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



# 刪除更新中的緩存
function Remove-WinUpdateStorage {
    $StoragePath1 = "$env:systemroot\SoftwareDistribution"
    # 關閉服務
    Stop-Service wuauserv
    # 刪除緩存
    if (!((Get-Service wuauserv).Status -eq "Stopped")) {
        Write-Host "錯誤:: Windows Update 服務還在運行中無法刪除 (請嘗試重新執行)"; return
    }
    if (Test-Path $StoragePath1) { Remove-Item $StoragePath1 -Recurse -Force }
    # 成功訊息
    Write-Host "已成功刪除 $StoragePath1 中的更新暫存檔"
} # Remove-WinUpdateStorage

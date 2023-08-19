# 測試登陸檔值是否存在
function Test-Registry {
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("PSPath")]
        [String] $Path,
        [Parameter(Position = 1)]
        [String] $Name,
        [Switch] $PassThru
    )
    $RegPath = $Path -replace("^HKEY_", "Registry::HKEY_")
    if (Test-Path $RegPath) {
        $RegKey = Get-Item $RegPath
        if ($Name) {
            if ($RegKey.GetValue($Name)) {
                if ($PassThru) {
                    return Get-ItemProperty $RegPath $Name
                } return $true
            }
        } else {
            if ($PassThru) {
                return $RegKey
            } return $true
        }
    } return $false
} # Test-Registry "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" AUOptions

# 刪除空機碼
function Remove-EmptyRegistryKey {
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("PSPath")]
        [String] $Path
    )
    $RegKey = $Path -replace("^HKEY_","Registry::HKEY_")
    if (Test-Path $RegKey) {
        if ((!(Get-ChildItem $RegKey) -and !(Get-ItemProperty $RegKey))) {
            Remove-Item $RegKey
        }
    }
} # Remove-EmptyRegistryKey "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

# 刪除機碼
function Remove-Registry {
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias("PSPath")]
        [String] $Path,
        [Parameter(Position = 1, Mandatory)]
        [object] $Name,
        [switch] $DeleteEmptyKey
    )
    $RegPath = $Path -replace("^HKEY_", "Registry::HKEY_")
    if (Test-Registry $RegPath $Name) { Remove-ItemProperty $RegPath $Name }
    if ($DeleteEmptyKey) { Remove-EmptyRegistryKey $RegPath }
} # Remove-Registry 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' AUOptions -DeleteEmptyKey





# 刪除更新中的緩存
function Remove-WinUpdateStorage {
    $DLPath = "$env:systemroot\SoftwareDistribution"
    # 關閉服務
    Stop-Service wuauserv; Start-Sleep 1
    while (!((Get-Service wuauserv).Status -eq "Stopped")) {
        Write-Host "正在嘗試停止 Windows Update 服務.."
        Stop-Service wuauserv|Out-Null; Start-Sleep 5
    }
    # 刪除緩存
    if (Test-Path $DLPath) { Remove-Item "$DLPath\*" -Recurse -Force }
    # 成功訊息
    Write-Output "已成功刪除 $DLPath 中的更新暫存檔"
} # Remove-WinUpdateStorage



# 停用自動更新
function StopWinUpdate {
    [Alias("Set-WinUpdate")]
    param(
        [Parameter(ParameterSetName = "A")]
        [switch] $Default,  # 群組原則恢復預設
        [Parameter(ParameterSetName = "B")]
        [switch] $Manual,   # 群組原則設定成手動
        [Parameter(ParameterSetName = "C")]
        [switch] $NotCheck, # 群組原則設定成不更新
        [Parameter(ParameterSetName = "D")]
        [switch] $Stop      # 關閉服務, 群組原則設定成手動
    )
    # 偵測版本
    if (((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").EditionID) -eq 'Core') { $IsWindowsHome=$true }
    # 群組原則對應的機碼位置
    $key1 = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $key2 = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    # 各項功能
    if ($Default) {
        # 家用版應對
        if ($IsWindowsHome) { if (Test-Path "C:\Windows\SoftwareDistribution\Download" -PathType:Leaf) { Remove-WinUpdateStorage|Out-Null } }
        # 群組原則恢復預設
        Remove-Registry $key2 AUOptions -EA:0
        Remove-Registry $key2 NoAutoRebootWithLoggedOnUsers -EA:0
        Remove-Registry $key2 NoAutoUpdate -EA:0
        Remove-EmptyRegistryKey $key2
        Remove-EmptyRegistryKey $key1
        # 啟動服務
        sc.exe config wuauserv start= delayed-auto |Out-Null
        Start-Service wuauserv
        Write-Host "已將更新恢復至預設狀態"
        return
    } elseif ($Manual) {
        # 家用版應對
        if ($IsWindowsHome) { Write-Warning "家用版無法透過群組原則設置手動更新，請使用 `"StopWinUpdate -Stop`" 停止更新"; return }
        # 群組原則設定成手動
        $regKey = $Key2 -replace("^HKEY_","Registry::HKEY_")
        if (!(Test-Path $regKey)) { New-Item $regKey -Force |Out-Null }
        New-ItemProperty $regKey 'AUOptions' -PropertyType:'DWord' -Value '00000002' -Force -EA:0 |Out-Null
        New-ItemProperty $regKey 'NoAutoRebootWithLoggedOnUsers' -PropertyType:'DWord' -Value '00000001' -Force -EA:0 |Out-Null
        Remove-Registry $key2 NoAutoUpdate -EA:0
        # 設置服務為手動
        Set-Service wuauserv -StartupType:Manual
        Stop-Service wuauserv
        Write-Host "已將更新設置為手動 (手動按下檢查後仍會自動下載並安裝)"
        return
    } elseif ($NotCheck) {
        # 家用版應對
        if ($IsWindowsHome) { Write-Warning "家用版無法透過群組原則設置手動更新，請使用 `"StopWinUpdate -Stop`" 停止更新"; return }
        # 群組原則設定成不檢查更新
        $regKey = $Key2 -replace("^HKEY_","Registry::HKEY_")
        if (!(Test-Path $regKey)) { New-Item $regKey -Force |Out-Null }
        Remove-Registry $key2 AUOptions -EA:0
        New-ItemProperty $regKey 'NoAutoRebootWithLoggedOnUsers' -PropertyType:'DWord' -Value '00000001' -Force -EA:0 |Out-Null
        New-ItemProperty $regKey 'NoAutoUpdate' -PropertyType:'DWord' -Value '00000001' -Force -EA:0 |Out-Null
        # 設置服務為手動
        Set-Service wuauserv -StartupType:Manual
        Stop-Service wuauserv
        Write-Host "已將更新設置為不檢查 (手動按下檢查後仍會自動下載並安裝)"
        return
    } elseif ($Stop) {
        # 停用服務
        Set-Service wuauserv -StartupType:Disabled
        Stop-Service wuauserv; Start-Sleep 1
        while (!((Get-Service wuauserv).Status -eq "Stopped")) {
            Write-Host "正在嘗試停止 Windows Update 服務.."
            Stop-Service wuauserv|Out-Null; Start-Sleep 5
        }
        # 家用版應對
        if ($IsWindowsHome) {
            Remove-WinUpdateStorage|Out-Null
            # if (Test-Path "C:\Windows\SoftwareDistribution\Download") { Remove-Item "C:\Windows\SoftwareDistribution\Download" -Recurse -Force; }
            New-Item "C:\Windows\SoftwareDistribution\Download" -ItemType:File |Out-Null
        }
        # 群組原則設定成手動(防止服務誤啟動)
        $regKey = $Key2 -replace("^HKEY_","Registry::HKEY_")
        if (!(Test-Path $regKey)) { New-Item $regKey -Force |Out-Null }
        New-ItemProperty $regKey 'AUOptions' -PropertyType:'DWord' -Value '00000002' -Force -EA:0 |Out-Null
        New-ItemProperty $regKey 'NoAutoRebootWithLoggedOnUsers' -PropertyType:'DWord' -Value '00000001' -Force -EA:0 |Out-Null
        Remove-Registry $key2 NoAutoUpdate -EA:0
        # 輸出信息
        Write-Host "已停用自動更新 (使用 `"StopWinUpdate -Default`" 命令可以恢復)"
        return
    }
}
# StopWinUpdate -Default
# StopWinUpdate -Manual
# StopWinUpdate -NotCheck
# StopWinUpdate -Stop



# 設定延緩更新的可選範圍上限
function Set-WinUpdatePauseMaxDays {
    [Alias("Set-WUPauseMax")]
    param (
        [Parameter(Position = 0, ParameterSetName = "Days", Mandatory)]
        [string] $Days,
        [Parameter(ParameterSetName = "Default")]
        [switch] $RestoreDefault
    )
    if ($RestoreDefault) {
        Remove-Registry "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" "FlightSettingsMaxPauseDays"
        Write-Host "已將延緩更新的可選範圍上限恢復為預設"
    } else {
        if ($Days -notmatch '^\d+$') { Write-Error "Error:: Days的輸入 '$Days' 有誤, 只能輸入正整數" -ErrorAction Stop }
        REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "FlightSettingsMaxPauseDays" /t REG_DWORD /d $Days /f |Out-Null
        Write-Host "已將延緩更新的可選範圍上限設置為 $Days 天"
    }
} # Set-WinUpdatePauseMaxDays -Days 90
#  Set-WinUpdatePauseMaxDays -RestoreDefault



# 延緩更新
function Set-WinUpdatePause {
    [Alias("Set-WUPause")]
    param (
        [Parameter(Position = 0, ParameterSetName = "Days", Mandatory)]
        [string] $Days,
        [Parameter(ParameterSetName = "RestoreDefault")]
        [switch] $RestoreDefault
    )
    
    if ($Days) {
        if ($Days -notmatch '^\d+$') { Write-Error "Error:: Days的輸入 '$Days' 有誤, 只能輸入正整數" -ErrorAction Stop }
        $startString = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        $endString = (Get-Date).AddDays([int]$Days).ToString("yyyy-MM-ddTHH:mm:ssZ")

        # 設定功能更新的暫緩時間
        REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /f /v "PauseFeatureUpdatesEndTime" /t REG_SZ /d $endString |Out-Null
        REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /f /v "PauseFeatureUpdatesStartTime" /t REG_SZ /d $startString |Out-Null
        # 設定質量更新的暫緩時間
        REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /f /v "PauseQualityUpdatesEndTime" /t REG_SZ /d $endString |Out-Null
        REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /f /v "PauseQualityUpdatesStartTime" /t REG_SZ /d $startString |Out-Null
        # 暫緩設定的有效期
        REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /f /v "PauseUpdatesExpiryTime" /t REG_SZ /d $endString |Out-Null
        
        Write-Host "已暫緩更新 $Days 日, 更新會在 $((Get-Date).AddDays([int]$Days+1).ToString("D")) 繼續"
    } elseif ($RestoreDefault) {
        Remove-Registry "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" "PauseFeatureUpdatesEndTime"
        Remove-Registry "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" "PauseFeatureUpdatesStartTime"
        Remove-Registry "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" "PauseQualityUpdatesEndTime"
        Remove-Registry "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" "PauseQualityUpdatesStartTime"
        Remove-Registry "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" "PauseUpdatesExpiryTime"
        Write-Host "已復原暫緩更新設定"
    }

} # Set-WinUpdatePause 30
# Set-WinUpdatePause -RestoreDefault



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



# 設定開發者測試通道
function OfflineInsiderEnroll {
    [Alias("Set-WinInsider")] param()
    $Url  = 'https://raw.githubusercontent.com/abbodi1406/offlineinsiderenroll/master/OfflineInsiderEnroll.cmd'
    $Path = $env:TEMP+ "\OfflineInsiderEnroll.cmd"
    $AsAdmin = '@echo off & fltmc >nul || (set Admin=/x /d /c call "%~f0" %* & powershell -nop -c start cmd $env:Admin -verb runas; & exit /b)'
    $Content = $AsAdmin + "`r`n" + (Invoke-RestMethod $Url).Trim("`r`n")
    $Content | Set-Content $Path
    cmd.exe /x /d /c call $Path
} # OfflineInsiderEnroll

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



# 設置 Windows Defender 防毒軟體
function Set-WinDefender {
    param(
        [Parameter(Position = 0, ParameterSetName = "Status", Mandatory)]
        [ValidateSet(
            'RestoreDefault',               # 0. 預設到Win全新安裝的狀態
            'Revert',                       # 1. 恢復程序帶來的所有變動
            'DisableAntiSpyware',           # 2. 停用防毒軟體
            'DisableRealtimeMonitoring'     # 3. 停用即時掃描
        )] [string] $Status,
        [Parameter(ParameterSetName = "")]
        [switch] $NotOpenSetting
    )
    # 獲取索引位置
    if ($PsCmdlet.ParameterSetName -eq 'Status') {
        $Table     = ((Get-Variable "Status").Attributes.ValidValues)
        $StatusIdx = [array]::IndexOf($Table, $Status)
    }
    # 設置 Windows Defender 防毒軟體
    if (!$Status) {
    } elseif ($StatusIdx -eq 0) { # RestoreDefault
        Remove-Item "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender"
        Write-Host "已恢復設定值到預設狀態"
    } elseif ($StatusIdx -eq 1) { # Revert
        Remove-Registry "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" DisableRealtimeMonitoring -DeleteEmptyKey
        Remove-Registry "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" DisableAntiSpyware
        Write-Host "已恢復程序帶來的所有變動"
    } elseif ($StatusIdx -eq 2) { # DisableAntiSpyware
        reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v DisableRealtimeMonitoring /t REG_DWORD /d 1 |Out-Null
        reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /f /v DisableAntiSpyware /t REG_DWORD /d 1 |Out-Null
        Write-Host "已關閉防毒軟體, 但新版 Windows 需要手動關閉 `"竄改防護`" 才會生效。" -ForegroundColor:Yellow
        Write-Host "  - 圖文說明可以參考作者網站說明 https://bit.ly/3sAmHhC"
    } elseif ($StatusIdx -eq 3) { # DisableRealtimeMonitoring
        reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v DisableRealtimeMonitoring /t REG_DWORD /d 1 |Out-Null
        Write-Host "已關閉即時掃描, 但新版 Windows 需要手動關閉 `"竄改防護`" 才會生效。" -ForegroundColor:Yellow
        Write-Host "  - 圖文說明可以參考作者網站說明 https://bit.ly/3sAmHhC"
    }
    # 打開 WindowsDefender 設定頁面
    if (!$NotOpenSetting) { Start-Process WindowsDefender://ThreatSettings }
} # Set-WinDefender DisableRealtimeMonitoring



# 關閉 Windows Defender 防毒軟體
function WindowsDefenderAntivirus {
    param(
        [Parameter(ParameterSetName = "")]
        [switch] $Disable,
        [Parameter(ParameterSetName = "")]
        [switch] $DisableRealtime,
        [Parameter(ParameterSetName = "")]
        [switch] $NotOpenSetting
    )
    if ($Disable) { # 關閉所有功能
        reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v DisableRealtimeMonitoring /t REG_DWORD /d 1
        reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /f /v DisableAntiSpyware /t REG_DWORD /d 1
        Write-Host "已關閉防毒軟體，但新版 Windows 需要手動關閉防竄改保護才會生效。" -ForegroundColor:Yellow
        Write-Host "  [右下角系統圖示::Windows安全性 -> 病毒與威脅防護 "
        Write-Host "     -> 病毒與威脅防護設定::管理設定 -> 防竄改保護::關閉此項目]"
        Write-Host "圖文說明可以參考這篇 https://bit.ly/3sAmHhC"
    } elseif ($DisableRealtime) { # 僅關閉即時掃描
        WindowsDefenderAntivirus -NotOpenSetting
        reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v DisableRealtimeMonitoring /t REG_DWORD /d 1
        Write-Host "已關閉即時掃描，但新版 Windows 需要手動關閉防竄改保護才會生效。" -ForegroundColor:Yellow
        Write-Host "  [右下角系統圖示::Windows安全性 -> 病毒與威脅防護 "
        Write-Host "     -> 病毒與威脅防護設定::管理設定 -> 防竄改保護::關閉此項目]"
        Write-Host "圖文說明可以參考這篇 https://bit.ly/3sAmHhC"
    } else { # 恢復為未設定狀態
        if (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -ErrorAction SilentlyContinue) {
            reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /f /v DisableAntiSpyware
        }
        if (Test-Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection") {
            reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f
        }
    }
    # 打開 WindowsDefender 設定頁面
    if (!$NotOpenSetting) { Start-Process WindowsDefender://ThreatSettings }
} # WindowsDefenderAntivirus -DisableRealtime

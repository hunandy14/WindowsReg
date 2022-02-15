function WindowsDefenderAntivirus {
    param(
        [Parameter(ParameterSetName = "")]
        [switch] $Disable,
        [Parameter(ParameterSetName = "")]
        [switch] $DisableRealtime
    )
    if ($Disable) { # 關閉所有功能
        WindowsDefenderAntivirus
        reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /f /v DisableAntiSpyware /t REG_DWORD /d 1
        Write-Host "已關閉防毒軟體。Windows11 需要手動關閉防竄改保護才會生效。" -ForegroundColor:Yellow
        Write-Host "  [右下角系統圖示::Windows安全性 -> 病毒與威脅防護 "
        Write-Host "     -> 病毒與威脅防護設定::管理設定 -> 防竄改保護::關閉此項目]"
    } elseif ($DisableRealtime) { # 僅關閉即時掃描
        WindowsDefenderAntivirus
        reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v DisableRealtimeMonitoring /t REG_DWORD /d 1
        Write-Host "已關閉即時掃描，但新版 Windows 需要手動關閉防竄改保護才會生效。" -ForegroundColor:Yellow
        Write-Host "  [右下角系統圖示::Windows安全性 -> 病毒與威脅防護 "
        Write-Host "     -> 病毒與威脅防護設定::管理設定 -> 防竄改保護::關閉此項目]"
    } else { # 恢復為未設定狀態
        if (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -ErrorAction SilentlyContinue) {
            reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /f /v DisableAntiSpyware
        }
        if (Test-Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection") {
            reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f
        }
    }
    Start-Process windowsdefender://threat
} # WindowsDefenderAntivirus -DisableRealtime

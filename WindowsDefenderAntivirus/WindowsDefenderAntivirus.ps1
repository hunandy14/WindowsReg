function WindowsDefenderAntivirus {
    param(
        [Parameter(ParameterSetName = "")]
        [switch] $Disable,
        [Parameter(ParameterSetName = "")]
        [switch] $DisableRealtime
    )
    if ($Disable) { # 關閉所有功能
        reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /f /v DisableAntiSpyware /t REG_DWORD /d 1
    } elseif ($DisableRealtime) { # 僅關閉即時掃描
        reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v DisableRealtimeMonitoring /t REG_DWORD /d 1
        Write-Host "已關閉即時掃描，但新版 Windows 需要你手動關閉防串改保護才會生效。"  -ForegroundColor:Yellow
        Write-Host "  設定 -> 更新與安全性 -> 開啟Windows安全性(按鈕)" -ForegroundColor:Yellow
        Write-Host "     -> 病毒與威脅防護 -> 病毒與威脅防護設定::管理設定 -> 防串改保護::關閉此項目" -ForegroundColor:Yellow
    } else { # 恢復為未設定狀態
        reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /f /v DisableAntiSpyware
        reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v DisableRealtimeMonitoring
    }
} # WindowsDefenderAntivirus -DisableRealtime

function UpgradeWinPro {
    param (
        [Switch] $Force
    )
    # 版本檢測
    $Version = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").EditionID
    if ($Version -eq 'Professional') {
        Write-Host "已經是 Windwos專業版 不需要升級" -ForegroundColor:Yellow; return
    }
    # 開始升級
    if (!$Force) {
        Write-Host "即將升級到 " -NoNewline
        Write-Host "Windwos專業版" -NoNewline -ForegroundColor:Yellow
        Write-Host ", 升級後無法復原請確定是否要升級, 完成後會立即重啟記得先存檔"
        $response = Read-Host "  沒有異議, 請輸入Y (Y/N) "
        if (($response -ne "Y") -or ($response -ne "Y")) { Write-Host "使用者中斷" -ForegroundColor:Red; return; }
        $response = Read-Host "  再次確認沒有異議, 請輸入Y (Y/N) "
        if (($response -ne "Y") -or ($response -ne "Y")) { Write-Host "使用者中斷" -ForegroundColor:Red; return; }
        Write-Host "開始升級到 Windwos專業版, 完成後會立即重啟, 過程中如果出現失敗請拔掉網線在離線狀態下升級"
        changepk.exe /ProductKey 'VK7JG-NPHTM-C97JM-9MPGT-3V66T'
    }
} UpgradeWinPro

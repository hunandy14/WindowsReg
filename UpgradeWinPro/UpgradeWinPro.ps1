# 升級WinPro
function UpgradeWinPro {
    param (
        [Switch] $Force
    )
    
    # 嚴格模式
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    # 檢查管理員權限
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "需要管理員權限才能執行, 請以管理員身份重新啟動終端機, 然後再次輸入指令。" -ForegroundColor Yellow; return
    }

    # Windows 版本相關資訊
    $WindowsInfo = [PSCustomObject]@{
        CurrentVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").EditionID
        HomeEditions = @("Home", "Core", "CoreSingleLanguage", "CoreCountrySpecific")
        ProfessionalEditions = @("Professional", "ProfessionalN", "ProfessionalWorkstation", "ProfessionalEducation")
    }
    
    # 檢查是否為專業版
    if ($WindowsInfo.CurrentVersion -in $WindowsInfo.ProfessionalEditions) {
        Write-Host "已經是 Windows專業版 不需要升級" -ForegroundColor:Yellow; return
    }
    # 檢查是否為家用版
    if ($WindowsInfo.CurrentVersion -notin $WindowsInfo.HomeEditions) {
        Write-Host "目前版本不是家用版，無法升級到專業版" -ForegroundColor:Red; return
    }
    
    # 開始升級
    Write-Host "即將升級到" -NoNewline; Write-Host " Windows專業版 " -NoNewline -ForegroundColor:Yellow
    Write-Host ", 升級後無法復原請確定是否要升級, 完成後會立即重啟記得先存檔"
    if (!$Force) {
        $response = Read-Host "  沒有異議, 請輸入Y (Y/N) "
        if ($response -ne "Y") { Write-Host "使用者中斷" -ForegroundColor:Red; return; }
        $response = Read-Host "  再次確認沒有異議, 請輸入Y (Y/N) "
        if ($response -ne "Y") { Write-Host "使用者中斷" -ForegroundColor:Red; return; }
    }
    
    # 變更產品金鑰
    try {
        Write-Host "即將開始升級到 Windows專業版 (如果出現失敗請拔掉網線在離線狀態下升級)"
        $process = Start-Process -FilePath "changepk.exe" -ArgumentList "/ProductKey VK7JG-NPHTM-C97JM-9MPGT-3V66T" -Wait -PassThru -NoNewWindow
        if ($process.ExitCode -ne 0) {
            Write-Host "產品金鑰變更失敗，錯誤代碼: $($process.ExitCode)" -ForegroundColor Red; return
        }; Write-Host "產品金鑰變更完畢，系統將在稍後自動重啟完成升級..." -ForegroundColor Green
    } catch {
        Write-Host "執行 changepk.exe 時發生錯誤: $_" -ForegroundColor Red; return
    }
    
} UpgradeWinPro

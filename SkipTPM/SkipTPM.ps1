# 原始碼
$URL = "https://raw.githubusercontent.com/AveYo/MediaCreationTool.bat/main/bypass11/Skip_TPM_Check_on_Dynamic_Update.cmd"
# 下載
$URL -match "[^/]+(?!.*/)" |Out-Null
$Path = $env:temp + $Matches[0]
Start-BitsTransfer $URL $Path
# 執行程序
if (Test-Path $Path) {
    explorer.exe $Path
} else { Write-Error "Error:: 檔案下載失敗" }

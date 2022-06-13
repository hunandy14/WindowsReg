function FirefoxUpdate {
    param (
        [switch] $Dislable,
        [switch] $Enable
    )
    $FileName = "policies.json"
    $FirfoxPath = "C:\Program Files\Mozilla Firefox"
    $File = "$FirfoxPath\distribution\$FileName"
    
    Try { [io.file]::OpenWrite("$FirfoxPath\update-settings.ini").close() }
    catch { Write-Warning "[權限不足]::需要管理員權限或開放火狐資料夾存取權限給當前使用者。"; return }
    
    if ($Dislable) {
        $Config = "`{
    `"policies`": `{
        `"DisableAppUpdate`": true
    `}
`}"
        if ( Test-Path $File ) { Move-Item $File "$File.backup2" -Force }
        New-Item $File -ItemType:File -Force -ErrorAction:Stop | Out-Null
        [System.IO.File]::WriteAllText($File, $Config)
        Write-Host "追加設定檔：" -NoNewline
        Write-Host $File -ForegroundColor:Yellow
        Get-Process|Where-Object{$_.ProcessName.Contains("firefox")} | Stop-Process
        Start-Process "C:\Program Files\Mozilla Firefox\firefox.exe"
        Write-Host "已停用火狐更新"
        
    } elseif ($Enable) {
        if ( Test-Path $File ) {
            Move-Item $File "$File.backup" -Force -ErrorAction:Stop 
            Get-Process|Where-Object{$_.ProcessName.Contains("firefox")} | Stop-Process
            Start-Process "C:\Program Files\Mozilla Firefox\firefox.exe"
        }
        Write-Host "已恢復火狐更新"
    }
} 
# FirefoxUpdate -Enable
# FirefoxUpdate -Dislable

function FirefoxUpdate {
    param (
        [switch] $Dislable,
        [switch] $Enable
    )
    $FileName = "policies.json"
    $FirfoxPath = "C:\Program Files\Mozilla Firefox"
    $File = "$FirfoxPath\distribution\$FileName"
    
    if ($Dislable) {
        $Config = "`{
    `"policies`": `{
        `"DisableAppUpdate`": true
    `}
`}"
        if ( Test-Path "$FirfoxPath\$FileName" ) {
            [System.IO.File]::WriteAllText($File, $Config)
        } else {
            Write-Host "追加設定檔：" "$FirfoxPath\$FileName"
            (New-Item $File -ItemType:File -Force)|Out-Null
            [System.IO.File]::WriteAllText($File, $Config)
        }
    } elseif ($Enable) {
        Move-Item $File "$File.backup"
    }
    
    Get-Process|Where-Object{$_.ProcessName.Contains("firefox")} | Stop-Process
    Start-Process "C:\Program Files\Mozilla Firefox\firefox.exe"
} # FirefoxUpdate -Dislable
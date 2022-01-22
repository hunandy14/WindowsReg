function Install-Regjump {
    $RegjumpSite = "https://download.sysinternals.com/files/regjump.zip"
    Start-BitsTransfer $RegjumpSite  $env:TEMP\regjump.zip
    Expand-Archive $env:TEMP\regjump.zip $env:TEMP -Force
    Copy-Item $env:TEMP\regjump.exe C:\Windows -Force
    regjump
}
function AutoUpgradeEdge {
    # 獲取當前版本資訊
    $EdgePath = (Get-ItemPropertyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe' "(default)")
    $CurrVer  = (Get-Item $EdgePath).VersionInfo.ProductVersion
    # 獲取最新版本資訊
    $Info     = (Invoke-RestMethod "https://edgeupdates.microsoft.com/api/products")[0].Releases[2]
    $NewVer   = $Info.ProductVersion
    $Url      = $Info.Artifacts.Location; $Url -match "[^/]+(?!.*/)" |Out-Null
    $FileName = $Matches[0]
    # 檢查版本
    if ($CurrVer -eq $NewVer) {
        Write-Host "Edge Already the latest version $CurrVer" -ForegroundColor:Yellow
    } else {
        $DLPath = "$env:TEMP\$NewVer\$FileName"
        if (!(Test-Path $DLPath)) { New-Item $DLPath -ItemType:File -Force|Out-Null } 
        Start-BitsTransfer $Url $DLPath
        Start-Process msiexec.exe -ArgumentList "/i $DLPath /qn /norestart" -Wait
        Write-Host "Edge has been updated to the latest version $NewVer" -ForegroundColor:Yellow
    }
} AutoUpgradeEdge

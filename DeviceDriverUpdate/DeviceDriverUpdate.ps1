function DeviceDriverUpdate {
    param (
        [Parameter(Position = 0, ParameterSetName = "")]
        [String] $Name
    )
    $Device = ((Get-WmiObject -Class CIM_PCVideoController)|Select-Object Name, PNPDeviceID)
    if ($Device -eq "") { Write-Host "ERROR:: No display Device" -F:yellow; return }
    $Device | Select-Object Name, PNPDeviceID
    
    $DeviceID = "PCI\"+($Device.PNPDeviceID.Split('\'))[1]
    
    $regPath1 = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions"
    $regPath2 = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs"
    
    if ($Recovery) {
        reg delete $regPath2
    } else {
        reg add $regPath1 /f /t "REG_DWORD" /v "DenyDeviceIDs" /d "1"
        reg add $regPath1 /f /t "REG_DWORD" /v "DenyDeviceIDsRetroactive" /d "0"
        reg add $regPath2 /f /t "REG_SZ" /v "1" /d $DeviceID
    }
} # DeviceDriverUpdate -Name:AMD


function DeviceDriverUpdate_XXXXXXX {
    param (
        [Parameter(Position = 0, ParameterSetName = "")]
        [String] $Name
    )
    if (!$Name) { #復原
        reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall" /f
        Write-Host "已恢復所有設備均可自動更新" -ForegroundColor:Yellow;
        return
    }
    $dev = (Get-PnpDevice -PresentOnly) -match($Name); $dev
    if ($dev.Count -eq 0) {
        Write-Host "找不到裝置..." -ForegroundColor:Yellow;
        return
    }
    Write-Host "是否禁用上述設備的自動更新" -ForegroundColor:Yellow;
    $response = Read-Host " 沒有異議，請輸入Y (Y/N) ";
    if ($response -ne "Y" -or $response -ne "Y") { Write-Host "使用者中斷" -ForegroundColor:Red; return; }
    
    # 禁用裝置
    reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions /v DenyDeviceIDs /t REG_DWORD /d 00000001 /f
    reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions /v DenyDeviceIDsRetroactive /t REG_DWORD /d 00000000 /f
    for ($i = 0; $i -lt $dev.Count; $i++) {
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs /v ($i+1) /d $dev.DeviceID[$i] /f
    }
    
    $env:Path = $env:Path+";C:\Program Files (x86)\Microsoft\Edge\Application"
    msedge.exe "https://charlottehong.blogspot.com/2022/01/nvidia-or-amd.html"
} # DeviceDriverUpdate -Name:"AMD|NVIDIA"
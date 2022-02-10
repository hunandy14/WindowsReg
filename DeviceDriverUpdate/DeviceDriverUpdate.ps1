function DeviceDriverUpdate {
    param (
        [Parameter(Position = 0, ParameterSetName = "")]
        [String] $Name
    )
    if($Name){
        irm bit.ly/3fqFUMs|iex; DisableVideoDriverUpdate -Name:$Name
    } else {
        irm bit.ly/3fqFUMs|iex; DisableVideoDriverUpdate -Recovery
    }
    
} # DeviceDriverUpdate -Name:AMD


# 廢棄錯了
function DeviceDriverUpdate_XXXXXXX {
    param (
        [Parameter(Position = 0, ParameterSetName = "")]
        [String] $Name
    )
    return
    
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
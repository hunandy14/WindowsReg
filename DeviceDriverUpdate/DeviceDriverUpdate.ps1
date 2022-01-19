function DeviceDriverUpdate {
    param (
        [String] $Name
    )
    if (!$Name) { #復原
        # reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall" /f
        return
    }
    $dev = (Get-PnpDevice -PresentOnly) -match($Name); $dev
    Write-Host "是否禁用上述設備的自動更新"
    $response = Read-Host " 沒有異議，請輸入Y (Y/N) ";
    if ($response -ne "Y" -or $response -ne "Y") { Write-Host "使用者中斷" -ForegroundColor:Red; return; }
    
    # 禁用裝置
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" /v DenyDeviceIDs /t REG_DROWD /d 00000001 /f
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" /v DenyDeviceIDsRetroactive /t REG_DROWD /d 00000000 /f
    $dev.DeviceID|ForEach-Object{ reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs" /v 1 /d $_ /f }
} # DeviceDriverUpdate -Name:"AMD|NVIDIA"
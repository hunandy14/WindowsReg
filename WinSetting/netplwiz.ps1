function netplwiz {
    param (
        [switch] $OnlyReg
    )
    $regPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device"
    $regItem = "DevicePasswordLessBuildVersion"
    $regValue = 0
    reg add $regPath /v $regItem /t REG_DWORD /d $regValue /f | Out-Null
    if (!$OnlyReg) { Netplwiz.exe }
} # netplwiz

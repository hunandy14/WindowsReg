function OnceRightClick {
    param (
        [switch] $Once
    )
    if ($Once) {
        reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /t REG_SZ /f
        Stop-Process -ProcessName explorer
    } else {
        reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
    }
} # OnceRightClick -Once
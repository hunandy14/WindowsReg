function Set-WinToGo {
    param (
        [Parameter(Position = 0, ParameterSetName = "Enable")]
        [switch] $Enable,
        [Parameter(Position = 0, ParameterSetName = "Disnable")]
        [switch] $Disable
    )
    if ($Enable) {
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v "PortableOperatingSystem" /t REG_DWORD /d "1" /f |Out-Null
        Write-Host "已開啟 WindowsToGo 模式"
    } elseif ($Disable) {
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v "PortableOperatingSystem" /t REG_DWORD /d "0" /f |Out-Null
        Write-Host "已關閉 WindowsToGo 模式"
    }
} # Set-WinToGo -Disable

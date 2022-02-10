function InstantGo {
    param (
        [Parameter(Position = 0, ParameterSetName = "Disable", Mandatory=$true)]
        [switch] $Disable,
        [Parameter(Position = 0, ParameterSetName = "Enable", Mandatory=$true)]
        [switch] $Enable,
        [Parameter(Position = 0, ParameterSetName = "Info", Mandatory=$true)]
        [switch] $Info
    )
    if ($Disable) {
        if (Get-ItemProperty -Path "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power" -Name CsEnabled -ErrorAction SilentlyContinue) {
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power" /v CsEnabled /t REG_DWORD /d 0 /f
        } else {
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power" /v PlatformAoAcOverride /t REG_DWORD /d 0 /f
        }
        Write-Host "執行完畢，重新啟動後生效" -ForegroundColor:Yellow
    } elseif ($Enable) {
        if (Get-ItemProperty -Path "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power" -Name CsEnabled -ErrorAction SilentlyContinue) {
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power" /v CsEnabled /t REG_DWORD /d 1 /f
        } else {
            reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power" /v PlatformAoAcOverride /f
        }
        Write-Host "執行完畢，重新啟動後生效" -ForegroundColor:Yellow        
    } elseif ($Info) {
        powercfg -a
    }
} # InstantGo -Info
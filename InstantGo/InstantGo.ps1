function DisableInstantGo {
    param (
        [Parameter(Position = 0, ParameterSetName = "Recovery")]
        [switch] $Recovery
    )
    # 檢查
    $IsLaptop = ((Get-WmiObject -Class Win32_ComputerSystem -Property PCSystemType).PCSystemType) -eq 2
    if (!$IsLaptop) { Write-Host "Error:: This PC is not Laptop." return }
    
    # 主功能
    $VersionFlag = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion[0]
    if ($VersionFlag -ne '1') {
        # Windwos 20H1 以後
        if (!$Recovery) {
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power" /v 'PlatformAoAcOverride' /t REG_DWORD /d 0 /f
        } else {
            if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name:'PlatformAoAcOverride' -EA:0) {
                reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power" /v 'PlatformAoAcOverride' /f
            }
            if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name:'CsEnabled' -EA:0) {
                reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power" /v 'CsEnabled' /f
            }
        }
    } else { 
        # Windwos 1903 以前
        if (!$Recovery) {
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power" /v 'CsEnabled' /t REG_DWORD /d 0 /f
        } else {
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power" /v 'CsEnabled' /t REG_DWORD /d 1 /f
        }
    }
}

function InstantGo {
    param (
        [Parameter(Position = 0, ParameterSetName = "Disable", Mandatory)]
        [switch] $Disable,
        [Parameter(Position = 0, ParameterSetName = "Enable", Mandatory)]
        [switch] $Enable,
        [Parameter(Position = 0, ParameterSetName = "Info", Mandatory)]
        [switch] $Info
    )
    if ($Disable) {
        DisableInstantGo
    } elseif ($Enable) {
        DisableInstantGo -Recovery
    } elseif ($Info) {
        Powercfg.exe -a
    }
}
# InstantGo -Disable
# InstantGo -Enable

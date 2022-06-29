function RegAdd {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [String] $Path,
        [Parameter(Position = 1, ParameterSetName = "", Mandatory)]
        [String] $Item,
        [Parameter(Position = 2, ParameterSetName = "", Mandatory)]
        [ValidateSet(
            'REG_SZ',
            'REG_MULTI_SZ',
            'REG_DWORD_BIG_ENDIAN',
            'REG_DWORD',
            'REG_BINARY',
            'REG_DWORD_LITTLE_ENDIAN',
            'REG_LINK',
            'REG_FULL_RESOURCE_DESCRIPTOR',
            'REG_EXPAND_SZ'
        )] [String] $Type,
        [Parameter(Position = 3, ParameterSetName = "", Mandatory)]
        [String] $Value,
        [switch] $OutNull,
        [switch] $OnlyOutCmd

    )
    $Cmd = "reg add `"$Path`" /v $Item /t $Type /d $Value /f"
    if ($OnlyOutCmd) {
        Write-Host $Cmd
    } else {
        if ($OutNull) { $Cmd = $Cmd + '|Out-Null' }
        Invoke-Expression $Cmd
    }
}
# $regPath  = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device"
# $regItem  = "DevicePasswordLessBuildVersion"
# $regType  = "REG_DWORD"
# $regValue = 0
# RegAdd $regPath $regItem $regType $regValue

function RegDel {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [String] $Path,
        [Parameter(Position = 1, ParameterSetName = "", Mandatory)]
        [String] $Item,
        [switch] $OutNull,
        [switch] $OnlyOutCmd
    )
    $Cmd = "reg delete `"$Path`" /v `"$Item`" /f"
    if ($OnlyOutCmd) {
        Write-Host $Cmd
    } else {
        if ($OutNull) { $Cmd = $Cmd + '|Out-Null' }
        if (Get-ItemProperty $('Registry::'+$Path) -Name:$Item -EA:0) {
            Invoke-Expression $Cmd
        }
    }
}

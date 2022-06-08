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
            'REG_EXPAND_SZ')]
        [String] $Type,
        [Parameter(Position = 3, ParameterSetName = "", Mandatory)]
        [String] $Value,
        [switch] $OutNull,
        [switch] $OnlyOutCmd
        
    )
    if ($OnlyOutCmd) {
        Write-Host reg add `"$Path`" /v $Item /t $Type /d $Value /f
    } else {
        if ($OutNull) {
            reg add $Path /v $Item /t $Type /d $Value /f | Out-Null
        } else {
            reg add $Path /v $Item /t $Type /d $Value /f
        }
    }
} 

# $regPath  = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device"
# $regItem  = "DevicePasswordLessBuildVersion"
# $regType  = "REG_DWORD"
# $regValue = 0
# RegAdd $regPath $regItem $regType $regValue

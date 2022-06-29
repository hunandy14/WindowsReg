function RegAdd {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [String] $Path,
        [Parameter(Position = 1, ParameterSetName = "A", Mandatory)]
        [String] $Item,
        [Parameter(Position = 1, ParameterSetName = "B", Mandatory)]
        [switch] $DefaultItem,
        [Parameter(Position = 2, ParameterSetName = "A", Mandatory)]
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
        [Parameter(Position = 3, ParameterSetName = "")]
        [String] $Value,
        
        [switch] $OutNull,
        [switch] $OnlyOutCmd
    )
    # 修正 Value
    if ($Value.Length -gt 0) { $Value = " /d `"$Value`"" }
    # 建立命令
    if ($DefaultItem) {
        $Cmd = "reg add `"$Path`" /ve" + $Value + " /f"
    } else {
        $Cmd = "reg add `"$Path`" /v `"$Item`" /t $Type" + $Value + " /f"
    }
    
    # 執行命令
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
# RegAdd $regPath $regItem $regType $regValue -OnlyOutCmd

# $regPath  = "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
# $regValue = ''
# RegAdd $regPath -DefaultItem $regValue -OnlyOutCmd

function RegDel {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [String] $Path,
        [Parameter(Position = 1, ParameterSetName = "A", Mandatory)]
        [String] $Item,
        [Parameter(Position = 1, ParameterSetName = "B", Mandatory)]
        [switch] $DefaultItem,
        [switch] $OutNull,
        [switch] $OnlyOutCmd
    )
    # 建立命令
    if ($DefaultItem) {
        $Cmd = "reg delete `"$Path`" /ve /f"
    } else {
        $Cmd = "reg delete `"$Path`" /v `"$Item`" /f"
    }
    # 執行命令
    if ($OnlyOutCmd) {
        Write-Host $Cmd
    } else {
        if ($OutNull) { $Cmd = $Cmd + '|Out-Null' }
        if (Get-ItemProperty $('Registry::'+$Path) -Name:$Item -EA:0) {
            Invoke-Expression $Cmd
        }
    }
}

# $regPath  = "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
# RegDel $regPath -DefaultItem -OnlyOutCmd

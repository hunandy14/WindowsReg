function RegAdd {
    param (
        # 1. 路徑
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [String] $Path,
        # 2. 名稱
        [Parameter(Position = 1, ParameterSetName = "A", Mandatory)]
        [String] $Name,
        [Parameter(Position = 1, ParameterSetName = "B", Mandatory)]
        [switch] $DefaultItem,
        # 3. 型態
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
        # 4. 值
        [Parameter(Position = 3, ParameterSetName = "")]
        [String] $Value,
        # 其他選項
        [Parameter(ParameterSetName = "")]
        [switch] $OutNull,
        [switch] $RunCmd
    )
    # 修正 Value
    if ($Value.Length -gt 0) { $Value = " /d `"$Value`"" }
    # 建立命令
    if ($DefaultItem) {
        $Cmd = "reg add `"$Path`" /ve" + $Value + " /f"
    } else {
        $Cmd = "reg add `"$Path`" /v `"$Name`" /t $Type" + $Value + " /f"
    }
    
    # 執行命令
    if (!$RunCmd) {
        return $Cmd
    } else {
        if ($OutNull) { $Cmd = $Cmd + '|Out-Null' }
        Invoke-Expression $Cmd
    }
}
# RegAdd "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" EditionID REG_SZ Core
# reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "EditionID" /t REG_SZ /d "Core" /f


function RegDel {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [String] $Path,
        [Parameter(Position = 1, ParameterSetName = "A", Mandatory)]
        [String] $Name,
        [Parameter(Position = 1, ParameterSetName = "B", Mandatory)]
        [switch] $DefaultItem,
        [switch] $OutNull,
        [switch] $OnlyOutCmd
    )
    # 建立命令
    if ($DefaultItem) {
        $Cmd = "reg delete `"$Path`" /ve /f"
    } else {
        $Cmd = "reg delete `"$Path`" /v `"$Name`" /f"
    }
    # 執行命令
    if ($OnlyOutCmd) {
        Write-Host $Cmd
    } else {
        if ($OutNull) { $Cmd = $Cmd + '|Out-Null' }
        if (Get-ItemProperty $('Registry::'+$Path) -Name:$Name -EA:0) {
            Invoke-Expression $Cmd
        }
    }
}

# $regPath  = "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
# RegDel $regPath -DefaultItem -OnlyOutCmd

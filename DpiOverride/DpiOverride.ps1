function CheckPath {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [string] $Path
    )
    # 檢查路徑
    $Path1=$Path
    if (!(Test-Path $Path -PathType:Leaf)) { Write-Error "路徑錯誤, 找不到 `"$Path`" 或他可能是個資料夾"; return }
    if ((Get-Item $Path).Extension -eq ".lnk") { $Path = ((New-Object -ComObject WScript.Shell).CreateShortcut($Path)).TargetPath }
    if ((Get-Item $Path).Extension -ne ".exe") { Write-Error "檔案類型錯誤, `"$Path`" 不是exe執行檔案"; return }
    return $Path
} # CheckPath "C:\Users\hunan\Desktop\Discord.lnk"

function Get-DpiOverride {
    $DpiOverridePath = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
    $ct = ("reg query '$DpiOverridePath'"|Invoke-Expression)
    $ct = $ct[2..($ct.Count-2)]
    $obj=@(); foreach ($item in ($ct -split "`n")) {
        $item = ($item -split "    ")
        $obj += [PSCustomObject]@{ "Program"=$item[1]; "DPI_Compatibility"=$item[3] }
    } return $obj|Sort-Object -Property DPI_Compatibility,Program
} # Get-DpiOverride

function Set-DpiOverride {
    [CmdletBinding(DefaultParameterSetName = "A")]
    param (
        [string] $Path,
        [Parameter(ParameterSetName = "A")]
        [string] $Value = "~ DPIUNAWARE",
        [Parameter(ParameterSetName = "B")]
        [switch] $Delete
    )
    $DpiOverridePath = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
    # 檢查路徑
    $Path = CheckPath $Path
    # 判定刪除或新增
    if ($Delete) {
        "reg delete $DpiOverridePath /v $Path /f"
    } else {
        "reg add $DpiOverridePath /v $Path /t REG_SZ /d $Value /f"
    }
}
# Set-DpiOverride "C:\Program Files\Synergy\synergy.exe"
# Set-DpiOverride "C:\Program Files\Synergy\synergy.exe" -Delete
# Set-DpiOverride "C:\Users\hunan\Desktop\Discord.lnk"

Function DpiTool {
    param (
        $Path
    )
    
} # DpiTool
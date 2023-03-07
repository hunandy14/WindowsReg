# 預設電源方案
[string] $Powercfg_PowerSaver      = 'a1841308-3541-4fab-bc81-f71556f20b4a'
[string] $Powercfg_Balanced        = '381b4222-f694-41f0-9685-ff5bb260df2e'
[string] $Powercfg_HighPerformance = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
[string] $Powercfg_Current         = 'scheme_current'
    
function GET-PowercfgScheme {
    Powercfg -List
}

function Copy-PowercfgScheme {
    [Alias('CopyScheme')]
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [string] $Name,     # 新增電源計畫名稱
        [Parameter(Position = 1, ParameterSetName = "")]
        [string] $GUID,     # 預設: 當前電源計畫
        [switch] $Apply,    # 新增後套用該計畫
        [switch] $OutNull   # 不輸出報告
    )
    # 未輸入已當前為主
    if (!$GUID) {
        $SchemeStr = Powercfg -GetActiveScheme
        $GUID = $SchemeStr.Substring($SchemeStr.IndexOf(' GUID: ')+7, 36)
    } else {
        $SchemeStr = (Powercfg -List) -match $GUID
        if (!$SchemeStr) { Write-Error "輸入的 GUID: `"$GUID`" 無效, 請輸入現有的電源計畫"; return $Null }
        $SchemeStr = $SchemeStr.Trim(" |*")
    }
    $SchemeName = $SchemeStr -replace($SchemeStr.Substring(0, $SchemeStr.IndexOf(' GUID: ')+7+38)) -replace ("^\(|\)$")
    # 複製計畫
    $SchemeStr = Powercfg -duplicatescheme $GUID
    if ($SchemeStr) { # 獲取新計畫的GUID
        $GUID2 = $SchemeStr.Substring($SchemeStr.IndexOf(' GUID: ')+7, 36)
        Powercfg -changename $GUID2 $Name
    }
    # 輸出報告
    $SchemeStr = ((Powercfg -List) -match $GUID2).Trim(" |*")
    if ($SchemeStr) {
        $SchemeName2 = $SchemeStr -replace($SchemeStr.Substring(0, $SchemeStr.IndexOf(' GUID: ')+7+38)) -replace ("^\(|\)$")
        if (!$OutNull) {
            Write-Host "電源計畫 `"" -NoNewline
            Write-Host "$SchemeName2" -NoNewline
            Write-Host "`" 複製完成, (複製源: `"$SchemeName`")"
        }
        if ($Apply) { Powercfg -setactive $GUID2 }
    }
    return $GUID2
} # Copy-PowercfgScheme "關閉睿頻" | Out-Null
# Copy-PowercfgScheme "關閉睿頻" -GUID $Powercfg_Balanced | Out-Null



function Set-PerfBoost {
    [CmdletBinding(DefaultParameterSetName = "Value")]
    param (
        [Parameter(Position = 0, ParameterSetName = "ValueMode", Mandatory)]
        [ValidateSet(
            'Disabled',           # 0. 已停用
            'Enabled',            # 1. 啟用
            'Aggressive',         # 2. 主動
            'EfficientEnabled',   # 3. 已啟用有效率
            'EfficientAggressive' # 4. 有效率地積極
        )] [string] $ValueMode,
        [Parameter(Position = 0, ParameterSetName = "Value", Mandatory)]
        [ValidateSet(0,1,2,3,4)]
        [uint16] $Value,
        [Parameter(Position = 1, ParameterSetName = "")]
        [string] $GUID,           # 預設: 當前電源計畫
        [switch] $Apply           # 套用該方案
    )
    # 預設參數初始化
    if (!$GUID) {
        $SchemeStr = [string](Powercfg -GetActiveScheme)
        $GUID   = $SchemeStr.Substring($SchemeStr.IndexOf(' GUID: ')+7, 36)
    } else {
        $SchemeStr = (Powercfg -List) -match $GUID
        if (!$SchemeStr) { Write-Error "輸入的 GUID: `"$GUID`" 無效, 請輸入現有的電源計畫"; return $Null }
        $SchemeStr = $SchemeStr.Trim(" |*")
    }
    $ModeTable = ((Get-Variable "ValueMode").Attributes.ValidValues)
    if ($PsCmdlet.ParameterSetName -eq 'ValueMode') {
        $Value = [array]::IndexOf($ModeTable, $ValueMode)
    } elseif ($PsCmdlet.ParameterSetName -eq 'Value') {
        $ValueMode = $ModeTable[$Value]
    }
    # 設置"處理器效能提升模式"為可見
    (reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7" /v Attributes /t REG_DWORD /d 2 /f) | Out-Null
    # 設置電源方案中"處理器效能提升模式"的模式
    Powercfg -setacvalueindex $GUID sub_processor PERFBOOSTMODE $Value
    Powercfg -setdcvalueindex $GUID sub_processor PERFBOOSTMODE $Value
    # 輸出報告
    if ($SchemeStr) {
        $SchemeName = $SchemeStr -replace($SchemeStr.Substring(0, $SchemeStr.IndexOf(' GUID: ')+7+38)) -replace ("^\(|\)$")
        Write-Host "處理器效能模式已設置為 `"$ValueMode`", (電源計畫: `"$SchemeName`")"
        if ($Apply) { Powercfg -setactive $GUID }
    }
}
# Set-PerfBoost -Apply
# Set-PerfBoost 0
# Set-PerfBoost Enabled
# Set-PerfBoost Disabled (Copy-PowercfgScheme "關閉睿頻") -Apply
# Set-PerfBoost Disabled -GUID:(Copy-PowercfgScheme "關閉睿頻" $Powercfg_Balanced) -Apply

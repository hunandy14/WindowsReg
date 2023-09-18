# 預設電源方案
Set-Variable -Name 'Powercfg_PowerSaver'      -Value 'a1841308-3541-4fab-bc81-f71556f20b4a'
Set-Variable -Name 'Powercfg_Balanced'        -Value '381b4222-f694-41f0-9685-ff5bb260df2e'
Set-Variable -Name 'Powercfg_HighPerformance' -Value '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
Set-Variable -Name 'Powercfg_Current'         -Value 'scheme_current'

# 獲取電源計畫清單
function GET-PowercfgScheme {
    Powercfg -List
}

# 複製電源計畫
function Copy-PowercfgScheme {
    [Alias('CopyScheme')]
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [string] $Name,                # 新增電源計畫名稱
        [switch] $WithoutOriginalName, # 生成計劃名不包含複製源名稱
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
    # 重新命名
    if ($SchemeStr) {
        $GUID2 = $SchemeStr.Substring($SchemeStr.IndexOf(' GUID: ')+7, 36)
        if (!$WithoutOriginalName) { $Name = "$SchemeName ($Name)" }
        Powercfg -changename $GUID2 $Name
    }
    
    # 輸出報告
    $SchemeStr = ((Powercfg -List) -match $GUID2).Trim(" |*")
    if ($SchemeStr) {
        $SchemeName2 = $SchemeStr -replace($SchemeStr.Substring(0, $SchemeStr.IndexOf(' GUID: ')+7+38)) -replace ("^\(|\)$")
        if (!$OutNull) {
            Write-Host "已建立電源計畫 `"" -NoNewline
            Write-Host "$SchemeName2" -NoNewline -ForegroundColor DarkGreen
            Write-Host "`" , 複製源: `"$SchemeName`""
        }
        if ($Apply) { Powercfg -setactive $GUID2 }
    }
    return $GUID2
} # Copy-PowercfgScheme "關閉睿頻" | Out-Null
# Copy-PowercfgScheme "關閉睿頻" -WithoutOriginalName | Out-Null
# Copy-PowercfgScheme "關閉睿頻" -GUID $Powercfg_Balanced | Out-Null


# 設定 PerfBoost
function Set-PerfBoost {
    [CmdletBinding(DefaultParameterSetName = "Value")]
    param (
        [Parameter(Position = 0, ParameterSetName = "StartupType", Mandatory)]
        [ValidateSet(
            'Disabled',           # 0. 已停用
            'Enabled',            # 1. 啟用
            'Aggressive',         # 2. 主動
            'EfficientEnabled',   # 3. 已啟用有效率
            'EfficientAggressive' # 4. 有效率地積極
        )] [string] $StartupType,
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
    $ModeTable = ((Get-Variable "StartupType").Attributes.ValidValues)
    if ($PsCmdlet.ParameterSetName -eq 'StartupType') {
        $Value = [array]::IndexOf($ModeTable, $StartupType)
    } elseif ($PsCmdlet.ParameterSetName -eq 'Value') {
        $StartupType = $ModeTable[$Value]
    }
    # 設置"處理器效能提升模式"為可見
    (reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7" /v Attributes /t REG_DWORD /d 2 /f) | Out-Null
    # 設置電源方案中"處理器效能提升模式"的模式
    Powercfg -setacvalueindex $GUID sub_processor PERFBOOSTMODE $Value
    Powercfg -setdcvalueindex $GUID sub_processor PERFBOOSTMODE $Value
    # 輸出報告
    if ($SchemeStr) {
        $SchemeName = $SchemeStr -replace($SchemeStr.Substring(0, $SchemeStr.IndexOf(' GUID: ')+7+38)) -replace ("^\(|\)$")
        Write-Host "處理器效能模式已設置為 `"$StartupType`", (電源計畫: `"$SchemeName`")"
        if ($Apply) { Powercfg -setactive $GUID }
    }
}
# Set-PerfBoost -Apply
# Set-PerfBoost 0
# Set-PerfBoost 1
# Set-PerfBoost 2
# Set-PerfBoost -StartupType Disabled
# Set-PerfBoost -StartupType Enabled
# Set-PerfBoost -StartupType Aggressive
# Set-PerfBoost Disabled (CopyScheme "關閉睿頻") -Apply
# Set-PerfBoost Disabled -GUID:(CopyScheme "關閉睿頻" $Powercfg_Balanced) -Apply

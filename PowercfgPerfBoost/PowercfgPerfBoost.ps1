# 預設電源方案
[string] $Powercfg_PowerSaver      = 'a1841308-3541-4fab-bc81-f71556f20b4a'
[string] $Powercfg_Balanced        = '381b4222-f694-41f0-9685-ff5bb260df2e'
[string] $Powercfg_HighPerformance = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
[string] $Powercfg_Current         = "scheme_current"
    
function GET-PowercfgScheme {
    powercfg.exe /l
}

function CopyScheme {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [string] $Name,
        [Parameter(Position = 1, ParameterSetName = "")]
        [string] $GUID,
        [switch] $Apply
    )
    # 未輸入已當前為主
    if (!$GUID) { $GUID = $Powercfg_Current}
    # 複製方案
    $newScheme = powercfg /duplicatescheme $GUID
    $GUID = $newScheme.Substring($newScheme.IndexOf(' GUID: ') + 7, 36)
    powercfg /changename $GUID $Name
    # 套用方案
    if ($Apply) { Powercfg -setactive $GUID }
    return $GUID
}
# CopyScheme "電池保護" $Powercfg_Balanced -Apply | Out-Null
# CopyScheme "電池保護" -Apply | Out-Null


function Set-PerfBoost {
    [CmdletBinding(DefaultParameterSetName = "B")]
    param (
        [Parameter(Position = 0, ParameterSetName = "")]
        [string] $Value,
        [Parameter(ParameterSetName = "A")]
        [switch] $CopyCurrent,
        [Parameter(Position = 1, ParameterSetName = "A")]
        [string] $Name,
        [Parameter(ParameterSetName = "B")]
        [string] $GUID,
        [switch] $Apply
    )
    if (!$Value) {
        Write-Host ''
        Write-Host '[錯誤]' -ForegroundColor:DarkRed -NoNewline
        Write-Host '::未輸入Value數值，使用方法請參考下列說明'
        Write-Host ''
        Write-Host '使用範例：'
        Write-Host '  Set-PerfBoost -Value:0' -ForegroundColor:Yellow
        Write-Host ''
        Write-Host 'Value: 數值意義'
        Write-Host '  0: 已停用'
        Write-Host '  1: 啟用'
        Write-Host '  2: 主動'
        Write-Host '  3: 已啟用有效率'
        Write-Host '  4: 有效率地積極'
        Write-Host ''
    } else {
        if (!$GUID) {
            $GUID = $Powercfg_Current
            if (!$CopyCurrent) { $Apply = $true }
        }

        if ($CopyCurrent) {
            if (!$Name) { $Name = "關閉超頻" } 
            $curScheme = (powercfg /query scheme_current)[0]
            $length = $curScheme.Length
            $index = $curScheme.IndexOf(' GUID: ')+ (7+36+2+1)
            $Name = $curScheme.Substring($index, $length-$index-1)+" ($Name)"
            # 設置參數
            $GUID = (CopyScheme $Name)
            $Apply = $true
        }
        # 執行
        (reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7" /v Attributes /t REG_DWORD /d 2 /f) | Out-Null
        Powercfg -setacvalueindex $GUID sub_processor PERFBOOSTMODE $Value
        Powercfg -setdcvalueindex $GUID sub_processor PERFBOOSTMODE $Value
        # 套用
        if ($Apply) { Powercfg -setactive $GUID }
    }
}
# Set-PerfBoost -Value:0
# Set-PerfBoost -Value:0 -CopyCurrent
# Set-PerfBoost -Value:0 -CopyCurrent "電池保護"
# Set-PerfBoost -Value:0 -GUID:(CopyScheme "電池保護") -Apply
# Set-PerfBoost -Value:0 -GUID:(CopyScheme "電池保護" $Powercfg_Balanced) -Apply

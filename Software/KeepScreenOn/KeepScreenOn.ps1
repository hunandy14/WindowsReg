###################################################################################################
# 獲取螢幕解析度
$__GetScreenInfoFlag__
function GetScreenInfo {
    if (!$__GetScreenInfoFlag__) {
    Add-Type -TypeDefinition:@"
using System;
using System.Runtime.InteropServices;
public class PInvoke {
    [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr hwnd);
    [DllImport("gdi32.dll")] public static extern int GetDeviceCaps(IntPtr hdc, int nIndex);
}
"@
    } $__GetScreenInfoFlag__ = $true
    
    $hdc = [PInvoke]::GetDC([IntPtr]::Zero)
    $Width   = [PInvoke]::GetDeviceCaps($hdc, 118)
    $Height  = [PInvoke]::GetDeviceCaps($hdc, 117)
    $Refresh = [PInvoke]::GetDeviceCaps($hdc, 116)
    $Scaling = [PInvoke]::GetDeviceCaps($hdc, 117) / [PInvoke]::GetDeviceCaps($hdc, 10)
    $LogicalHeight =  [PInvoke]::GetDeviceCaps($hdc, 10)
    $LogicalWeight =  [PInvoke]::GetDeviceCaps($hdc, 8)
   
    [pscustomobject]@{
        Width         = $Width
        Height        = $Height
        Refresh       = $Refresh
        # Scaling       = [Math]::Round($Scaling, 3)
        Scaling       = $Scaling
        LogicalHeight = $LogicalHeight
        LogicalWeight = $LogicalWeight
    }
} $ScreenInfo = GetScreenInfo

# 獲取當前滑鼠座標
function Get-CursorPosition {
    param (
        [int16] $OffsetX=0,
        [int16] $OffsetY=0,
        [switch] $Normalization
    )
    # 獲取當前座標
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $Pos = [System.Windows.Forms.Cursor]::Position
    # 獲取解析度
    Add-Type -AssemblyName System.Windows.Forms
    $Res = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize
    # 正規化
    $x = [double]($Pos.X)/($Res.Width) 
    $y = [double]($Pos.Y)/($Res.Height)
    # 補償係數 (計算方法是把滑鼠移動到右下角然後用1去除以得到的數，不同解析度補償可能不同這邊用2K做的)
    $x = $x*1.00058616647127884
    $y = $y*1.00093808630394
    # 解析到真實解析度
    $x = $x*($ScreenInfo.Width) 
    $y = $y*($ScreenInfo.Height)
    # 計算位移
    $x = $x+$OffsetX
    $y = $y+$Offsety
    # 正規化
    if ($Normalization) {
        $x = $x/($ScreenInfo.Width) 
        $y = $y/($ScreenInfo.Height)
    }
    # 輸出
    [PSCustomObject]@{ X = $x; Y = $y }
} # Get-CursorPosition

# 設置滑鼠座標
Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void mouse_event(int flags, int dx, int dy, int cButtons, int info);' -Name U32 -Namespace W;
function Set-CursorPosition {
    param (
        [double] $X,
        [double] $Y,
        [switch] $Rate
    )
    # 正規化
    if (!$Rate) {
        $X = $X/($ScreenInfo.Width) 
        $Y = $Y/($ScreenInfo.Height)
    }
    # 設定左標
    [W.U32]::mouse_event(0x8000 -bor 0x001, $X*65535, $Y*65535, 0, 0);
} # Set-CursorPosition (Get-CursorPosition 100); sleep 1; Set-CursorPosition (Get-CursorPosition -100)


###################################################################################################
# 保持螢幕亮著 (https://gist.github.com/jamesfreeman959/231b068c3d1ed6557675f21c0e346a9c)
function KeepScrOn {
    Param(
        [UInt64] $Time=59, 
        [UInt64] $Offset=1, 
        [Switch] $Debug
    )
    if ($Debug) {$Offset=100}
    $Msg = "Running KeepScrOn... (Press Ctrl+C to end.)"
    Write-Host "[$((Get-Date).Tostring("yyyy/MM/dd HH:mm:ss.fff"))] $Msg"
    # 開始循環
    while (1) {
        # 讀取當前位置
        $Pos = (Get-CursorPosition)
        # 向右偏移
        Set-CursorPosition ($Pos.X+$Offset) ($Pos.Y)
        # 檢測是否有偏移，沒偏移就是滑鼠在邊界
        if(($Pos.X) -eq ((Get-CursorPosition).X)){ Set-CursorPosition ($Pos.X-$Offset) ($Pos.Y) } 
        # 偵錯的時候向右偏移延遲1秒比較看的出來
        if ($Debug) { Start-Sleep -Seconds 1 }
        # 偏移回原本的位置
        Set-CursorPosition ($Pos.X) ($Pos.Y)
        # 每隔多久偏移一次
        Start-Sleep -Seconds $Time
    }
} # KeepScrOn 1 -Debug


###################################################################################################

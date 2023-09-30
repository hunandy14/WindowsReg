###################################################################################################
# 獲取螢幕解析度
function GetScreenInfo {
    if (!$__GetScreenInfoOnce__) { $Script:__GetScreenInfoOnce__ = $true
        Add-Type -TypeDefinition:'using System; using System.Runtime.InteropServices; public class PInvoke { [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr hwnd); [DllImport("gdi32.dll")] public static extern int GetDeviceCaps(IntPtr hdc, int nIndex); }'
    }
    $hdc = [PInvoke]::GetDC([IntPtr]::Zero)
    [pscustomobject]@{
        Width         = [PInvoke]::GetDeviceCaps($hdc, 118)
        Height        = [PInvoke]::GetDeviceCaps($hdc, 117)
        Refresh       = [PInvoke]::GetDeviceCaps($hdc, 116)
        Scaling       = [PInvoke]::GetDeviceCaps($hdc, 117) / [PInvoke]::GetDeviceCaps($hdc, 10)
        LogicalWeight = [PInvoke]::GetDeviceCaps($hdc, 8)
        LogicalHeight = [PInvoke]::GetDeviceCaps($hdc, 10)
    }
} $ScreenInfo = (GetScreenInfo) # ;$ScreenInfo

# 獲取當前滑鼠座標
function Get-CursorPosition {
    param (
        [int16] $OffsetX=0,
        [int16] $OffsetY=0,
        [switch] $Normalization
    )
    # 更新螢幕資訊
    $ScreenInfo = (GetScreenInfo)
    # 獲取當前座標
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $Pos = [System.Windows.Forms.Cursor]::Position
    # 正規化[0~1]
    $x = [double]($Pos.X)/($ScreenInfo.LogicalWeight)
    $y = [double]($Pos.Y)/($ScreenInfo.LogicalHeight)
    # 補償係數 (計算方法是把滑鼠移動到右下角然後用1去除以得到的數，不同解析度補償可能不同這邊用2K做的)
    # $x = $x*1.00058616647127884
    # $y = $y*1.00093808630394
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
    [PSCustomObject]@{ X=$x; Y=$y }
} # Get-CursorPosition

# 設置滑鼠座標
function Set-CursorPosition {
    param (
        [double] $X,
        [double] $Y,
        [switch] $DeNormalization
    )
    # 載入函式
    if (!$__Set_MouseEvent_Once__) { $Script:__Set_MouseEvent_Once__ = $true
        Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void mouse_event(int flags, int dx, int dy, int cButtons, int info);' -Name U32 -Namespace W;
    }
    # 正規化[0-1]
    if (!$DeNormalization) {
        $X = $X/($ScreenInfo.Width)
        $Y = $Y/($ScreenInfo.Height)
    }
    # 防止超出主螢幕
    if ($X -gt 1) { $X = 1 }
    if ($Y -gt 1) { $Y = 1 }
    # 設定座標(正規化[0~65535])
    [W.U32]::mouse_event(0x8000 -bor 0x001, $X*65535, $Y*65535, 0, 0);
} 
# $Pos = Get-CursorPosition
# $Pos
# Set-CursorPosition ($Pos.X+100) ($Pos.Y)
# Start-Sleep 1
# Set-CursorPosition ($Pos.X) ($Pos.Y)


###################################################################################################
# 保持螢幕亮著 (https://gist.github.com/jamesfreeman959/231b068c3d1ed6557675f21c0e346a9c)
function KeepScrOn {
    Param(
        [Double] $Time = 59,
        [Double] $Offset = 1,
        [Switch] $Debug
    )
    if ($Debug) { $Time=3; $Offset=100 }
    $Msg = "Running KeepScrOn_Mouse... (Press Ctrl+C to exit.)"
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
} # KeepScrOn -Debug

# 按鍵式的 (上面的函式沒辦法對應滑鼠跑到非主螢幕上)
function KeepScrOn2 {
    param (
        [Double] $Time = 59,
        [String] $Key = '{SCROLLLOCK}',
        [Double] $Intervals =0.01,
        [Switch] $Debug
    )
    # 偵錯模式
    if ($Debug) { $Key = '{CAPSLOCK}'; $Time=0.5; $Intervals=500 }
    # 加載函數
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $WShell = New-Object -ComObject WScript.Shell
    # 提示訊息
    $Msg = "Running KeepScrOn_key... (Press Ctrl+C to exit.)"
    Write-Host "[$((Get-Date).Tostring("yyyy/MM/dd HH:mm:ss.fff"))] $Msg"
    # 起始檢測
    foreach($item in (1..4)){ $WShell.SendKeys('{CAPSLOCK}'); Start-Sleep -Milliseconds 100; }
    # 開始循環
    while (1) {
        Start-Sleep $Time
        $WShell.SendKeys($Key)
        Start-Sleep -Milliseconds $Intervals
        $WShell.SendKeys($Key)
    }
} # KeepScrOn2 -Debug


###################################################################################################
# 安裝到電腦上
function Install-App {
    param (
        [string] $Path,
        [string] $Argu="KeepScrOn -Time:59",
        [string] $WindowsStyle="Mini"
    )
    # 設定參數
    $FileName = "C:\ProgramData\PwshApp\KeepScreenOn\KeepScreenOn.ps1"
    if ($Path) { $FileName = $Path }
    $EncCMD = "[Text.Encoding]::GetEncoding('UTF-8')"
    $Enc = $EncCMD|Invoke-Expression
    # 下載
    $text = Invoke-RestMethod 'raw.githubusercontent.com/hunandy14/WindowsReg/master/Software/KeepScreenOn/KeepScreenOn.ps1'
    $EncodedText = ([Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($Text))).Tostring()
    $key = $EncodedText[0]; $reg = "^[\s\S]{1}"
    if ($EncodedText[0] -ne 'C') { $EncodedText = $EncodedText -replace($reg,'C') } else { $EncodedText = $EncodedText -replace($reg,'D') }
    # 輸出到檔案
    (New-Item $FileName -ItemType:File -Force)|Out-Null
    [IO.File]::AppendAllText($FileName, $EncodedText, $Enc)
    # 建立捷徑
    [string] $SourceExe       = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    [string] $Arguments       = $Argu
    [string] $DestinationPath = [Environment]::GetFolderPath("Desktop") + "\Keep.lnk"
    # 處理命令
    $Text = "([System.Io.File]::ReadAllText('$FileName', $EncCMD) -replace (`'$reg`', `'$key`'))"
    $Arguments = "-NoP -Window $WindowsStyle -C `"[System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Text)) | iex; $Arguments`""
    # 處理捷徑
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($DestinationPath)
    $Shortcut.TargetPath = $SourceExe
    $Shortcut.Arguments = $Arguments
    $Shortcut.Save()
    # 通知
    Write-Host "Shortcuts have been created to " -NoNewline
    Write-Host "`"$DestinationPath`"" -ForegroundColor:Yellow
    # explorer.exe $DestinationPath
} # Install-App "C:\ProgramData\Adobe\Temp\keep"


###################################################################################################

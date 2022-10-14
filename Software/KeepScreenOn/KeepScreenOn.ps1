# 保持螢幕亮著
function KeepScrOn ([UInt64] $Time=59, $Offset = 1, [Switch] $Debug) {
    # https://gist.github.com/jamesfreeman959/231b068c3d1ed6557675f21c0e346a9c
    $Msg = "Running KeepScrOn... (Press Ctrl+C to end.)"
    Write-Host "[$((Get-Date).Tostring("yyyy/MM/dd HH:mm:ss.fff"))] $Msg"
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    while (1) {
        $Pos = [System.Windows.Forms.Cursor]::Position
        [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point((($Pos.X)+$Offset), $Pos.Y)
        if($Pos -eq [System.Windows.Forms.Cursor]::Position){
            [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point((($Pos.X)-$Offset), $Pos.Y)
        }
        if ($Debug) { Start-Sleep -Seconds 0.1 }
        [System.Windows.Forms.Cursor]::Position = $Pos
        Start-Sleep -Seconds $Time
    }
} # KeepScrOn -Time 3 -Offset 100 -Debug

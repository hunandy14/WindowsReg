# https://www.reddit.com/r/edge/comments/s0dmqz/global_media_controls_missing_in_970107255

function EdgeMediaControls {
    param (
        [switch]$Desktop,
        [switch]$Start
    )
    $userDsk = [Environment]::GetFolderPath("Desktop")
    
    if ($Desktop) {
        
    } elseif ($Start) {
        
    }
    # 重啟到 MediaControls 模式
    Get-Process|Where-Object{$_.ProcessName.Contains("msedge")} | Stop-Process
    Start-Process $edgePath -ArgumentList:$edgeArgs
    
    Start-BitsTransfer https://download.sysinternals.com/files/regjump.zip "$userDsk\Edge Media Controls"
}

# $shortcutName = "Edge_MediaControls"
# $edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
# $edgeArgs = "--enable-features=GlobalMediaControls"

# $shell = New-Object -ComObject WScript.Shell
# $userDsk = [Environment]::GetFolderPath("Desktop")

# $shortcut = $shell.CreateShortcut("$userDsk\$shortcutName`.lnk")
# $shortcut.TargetPath = $edgePath
# $shortcut.Arguments = $edgeArgs
# $shortcut.Save()

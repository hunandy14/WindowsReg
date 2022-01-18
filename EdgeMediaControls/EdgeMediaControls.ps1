# https://www.reddit.com/r/edge/comments/s0dmqz/global_media_controls_missing_in_970107255

function EdgeMediaControls {
    param (
        [switch]$Desktop,
        [switch]$Start
    )
    if ($Desktop) {
        $Path = [Environment]::GetFolderPath("Desktop")
    } elseif ($Start) {
        $Path = "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup"
    }
    # 重啟到 MediaControls 模式
    $edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    $edgeArgs = "--enable-features=GlobalMediaControls"
    Get-Process|Where-Object{$_.ProcessName.Contains("msedge")} | Stop-Process
    Start-Process $edgePath -ArgumentList:$edgeArgs
    # 安裝到指定位置
    if ($Path) {
        $shortcutName = "Edge Media Controls.lnk"
        $Link = "https://github.com/hunandy14/WindowsReg/raw/master/EdgeMediaControls/Edge%20Media%20Controls.lnk"
        Start-BitsTransfer $Link "$Path\$shortcutName"
    }
}

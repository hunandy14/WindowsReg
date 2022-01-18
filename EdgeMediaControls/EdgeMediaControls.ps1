# https://www.reddit.com/r/edge/comments/s0dmqz/global_media_controls_missing_in_970107255

function EdgeMediaControls {
    param (
        [switch]$Desktop,
        [switch]$Start,
        [switch]$StartUp
    )
    # 重啟到 MediaControls 模式
    $edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    $edgeArgs = "--enable-features=GlobalMediaControls"
    Get-Process|Where-Object{$_.ProcessName.Contains("msedge")} | Stop-Process
    Start-Process $edgePath -ArgumentList:$edgeArgs
    # 安裝到指定位置
    $shortcutName = "Microsoft Edge.lnk"
    $Link = "https://github.com/hunandy14/WindowsReg/raw/master/EdgeMediaControls/Microsoft%20Edge.lnk"
    if ($Desktop) {
        $Path = [Environment]::GetFolderPath("Desktop")
        Start-BitsTransfer $Link "$Path\$shortcutName"
    } if ($Start) {
        # $Path = "$env:AppData\Microsoft\Windows\Start Menu\Programs"
        $Path = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
        Start-BitsTransfer $Link "$Path\$shortcutName"
    } if ($StartUp) {
        $Path = "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup"
        Start-BitsTransfer $Link "$Path\$shortcutName"
    }
}

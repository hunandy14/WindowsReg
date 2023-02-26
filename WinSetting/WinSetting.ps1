# ==================================================================================================
# 系統設定::通常設定
function Setting_System{
    # UAC 不要把桌面變黑
    irm bit.ly/SetWinUAC|iex; SetUAC -Set:1
    # 設定成手動更新
    irm bit.ly/3GAuGRF|iex; StopWinUpdate -Manual
    # 關閉及時掃描
    irm bit.ly/3GACH9d|iex; WindowsDefenderAntivirus -DisableRealtime
}
# 系統設定::測試用虛擬機設定
function Setting_System2{
    # 關閉 UAC
    irm bit.ly/SetWinUAC|iex; SetUAC -Set:0
    # 設定成手動更新
    irm bit.ly/3GAuGRF|iex; StopWinUpdate -Stop
    # 關閉防毒
    irm bit.ly/3GACH9d|iex; WindowsDefenderAntivirus -DisableRealtime
}
# 使用者設定::通常
function Setting_User {
    # 去除捷徑字樣
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer" /v link /t REG_BINARY /d 00000000 /f
    # 檔案管理員預設打開(1本機 2快速存取)
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /t REG_DWORD /d 2 /f
    
    # 工作列按鈕不要合併(0結合 1滿時結合 2不結合)
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarGlomLevel /t REG_DWORD /d 2 /f
    # 顯示副檔名
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f
    # 顯示隱藏檔案
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 0 /f
    # 顯示隱藏系統檔
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSuperHidden /t REG_DWORD /d 1 /f
    # 打開上一次登入時的資料夾
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v PersistBrowsers /t REG_DWORD /d 1 /f
    
    # 桌面圖示 - 使用者文件
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" /t REG_DWORD /d 0 /f
    # 桌面圖示 - 本機
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d 0 /f
    # 桌面圖示 - 本機
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" /t REG_DWORD /d 0 /f
    # 桌面圖示 - 控制台
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" /t REG_DWORD /d 1 /f
    # 桌面圖示 - 資源回收桶
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /t REG_DWORD /d 0 /f
    if ((Get-Process -ProcessName:'explorer' -ErrorAction:SilentlyContinue)) { Stop-Process -ProcessName:'explorer' }

    # 開機時自動打開鍵盤 NumLock 燈號
    if ($env:USERNAME -ne 'SYSTEM') {
        $UserSID  = (Get-LocalUser $env:USERNAME).sid.value
        reg add "HKEY_USERS\$UserSID\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d 2 /f
    } reg add "HKEY_USERS\.DEFAULT\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d 2 /f
    
    # 新注音預設為英文狀態 (英文:0x00000001, 繁體:0x00000000)
    reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\IME\15.0\IMETC" /v "Default Input Mode" /t REG_SZ /d "0x00000001" /f
    
    # 啟用剪貼簿歷史
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Clipboard" /v "EnableClipboardHistory" /t REG_DWORD /d 1 /f
    
    # netplwiz 恢復自動登入選項
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device" /v "DevicePasswordLessBuildVersion" /t REG_DWORD /d 0 /f
    
    # 關閉 WindowsStore 的自動更新 (關閉:2, 開啟:4)
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d 2 /f
    
    # rdp遠端桌面連線啟用60fps
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations" /v "DWMFRAMEINTERVAL" /t REG_DWORD /d 15 /f
    
    # 禁止Edge更新時在桌面建立捷徑
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "CreateDesktopShortcutDefault" /t REG_DWORD /d 0 /f
    
    # 關閉 Windwos 開機提示"讓我們完成你的電腦設定"的蓋板頁面
    reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d 0 /f
}
# ==================================================================================================
# 個人用設定
function CHG_Setting {
    Setting_User
    Setting_System
}
# 測試用系統
function VM_Setting {
    Setting_User
    # 檔案管理員預設打開(1本機 2快速存取)
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /t REG_DWORD /d 1 /f
    # Win111自動展開右鍵
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /t REG_SZ /f
    # 停用驅動更新模組
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v ExcludeWUDriversInQualityUpdate /t REG_DWORD /d 1 /f
    # 停用Windows 11桌面右下方「不符合系統需求」浮水印
    reg add "HKEY_CURRENT_USER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d 0 /f
    # 系統設定
    Setting_System2
}
function VM_Setting2 {
    # 虛擬機設定
    VM_Setting
    # 安裝軟體
    Set-ExecutionPolicy Bypass -S:Process -F; irm chocolatey.org/install.ps1|iex
    choco install -y 7zip
    choco install -y git --params "/NoShellIntegration"
    choco install -y git vscode
    # choco install -y powershell-core
    # choco install -y powertoys
}

function Soft {
    Set-ExecutionPolicy Bypass -S:Process -F
    irm chocolatey.org/install.ps1|iex
    
    choco install -y powertoys
    choco install -y 7zip
    choco install -y javaruntime
    choco install -y adobereader
    choco install -y googlechrome
    choco install -y k-litecodecpackmega
    choco install -y line
}

function WindowsActive {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory=$true)]
        [string] $KMS
    )
    slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
    slmgr /skms $KMS
    slmgr /ato
}
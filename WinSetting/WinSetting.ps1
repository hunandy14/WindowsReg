# ==================================================================================================
# 系統設定::通常設定
function Setting_System{
        # UAC 不要把桌面變黑
        irm bit.ly/3Gca80R|iex; SetUAC -Set:1
        # 設定成手動更新
        irm bit.ly/3GAuGRF|iex; AutomaticUpdates -Manual
        # 關閉及時掃描
        irm bit.ly/3GACH9d|iex; WindowsDefenderAntivirus -DisableRealtime
}
# 系統設定::測試用虛擬機設定
function Setting_System2{
    # 關閉 UAC
    irm bit.ly/3Gca80R|iex; SetUAC -Set:0
    # 設定成手動更新
    # irm bit.ly/3GAuGRF|iex; AutomaticUpdates -Stop
    irm bit.ly/3GAuGRF|iex; AutomaticUpdates -Manual
    # 關閉防毒
    irm bit.ly/3GACH9d|iex; WindowsDefenderAntivirus -Disable
}
# 使用者設定::通常
function Setting_User {
    # 去除捷徑字樣
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer" /v link /t REG_BINARY /d 00000000 /f
    # 檔案管理員預設打開(1本機 2快速存取)
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /t REG_DWORD /d 2 /f
    
    # 工作列按鈕不要合併
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarGlomLevel /t REG_DWORD /d 1 /f
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
    Stop-Process -ProcessName explorer

    # NumLock
    reg add "HKEY_USERS\.DEFAULT\Control Panel\Keyboard" /v InitialKeyboardIndicators /t REG_SZ /d 2147483650 /f
    
    # 新注音預設為英文狀態
    reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\IME\15.0\IMETC" /v "Default Input Mode" /t REG_SZ /d "0x00000001" /f
    # 新注音預設為繁體狀態
    # reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\IME\15.0\IMETC" /v "Enable Simplified Chinese Output" /t REG_SZ /d "0x00000000" /f
    
    # 啟用剪貼簿歷史
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Clipboard" /v "EnableClipboardHistory" /t REG_DWORD /d 1 /f
    
    # netplwiz 恢復自動登入選項
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device" /v "DevicePasswordLessBuildVersion" /t REG_DWORD /d 0 /f
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
    
    # 關閉 UAC
    irm bit.ly/3Gca80R|iex; SetUAC -Set:0
    # 設定成手動更新
    irm bit.ly/3GAuGRF|iex; AutomaticUpdates -Stop
    # 關閉防毒
    irm bit.ly/3GACH9d|iex; WindowsDefenderAntivirus -Disable
}
function VM_Setting2 {
    Setting_User
    # 檔案管理員預設打開(1本機 2快速存取)
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /t REG_DWORD /d 1 /f
    
    
    # 關閉 UAC
    irm bit.ly/3Gca80R|iex; SetUAC -Set:0
    # 設定成手動更新
    irm bit.ly/3GAuGRF|iex; AutomaticUpdates -Stop
    # 關閉防毒
    irm bit.ly/3GACH9d|iex; WindowsDefenderAntivirus -Disable
    
    
    Set-ExecutionPolicy Bypass -S:Process -F
    irm chocolatey.org/install.ps1|iex
    choco install -y 7zip
    choco install -y vscode
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
        [string] $KMS
    )
    slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
    slmgr /skms $KMS
    slmgr /ato
}
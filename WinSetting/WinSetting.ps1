# ==================================================================================================
# 系統設定::通常設定
function Setting_System{
    # UAC 不要把桌面變黑
    irm bit.ly/SetWinUAC|iex; SetUAC -Set:1
    # 設定更新為手動(自動檢查)
    irm bit.ly/SetWinUpd|iex; Set-WinUpdate -Manual
    # 關閉及時掃描
    irm bit.ly/SetWinDA|iex; Set-WinDefender DisableRealtimeMonitoring
}
# 系統設定::測試用虛擬機設定
function Setting_System2{
    # 關閉 UAC
    irm bit.ly/SetWinUAC|iex; SetUAC -Set:0
    # 關閉自動更新
    irm bit.ly/SetWinUpd|iex; Set-WinUpdate -Stop
    # 關閉即時掃描
    irm bit.ly/SetWinDA|iex; Set-WinDefender DisableRealtimeMonitoring
    # 關閉索引服務 (sc.exe config wsearch start= delayed-auto|Out-Null; Start-Service WSearch)
    Set-Service WSearch -StartupType:Disabled; Stop-Service WSearch
    # 設定Windows密碼永不過期
    Set-LocalUser -Name "$env:USERNAME" -PasswordNeverExpires 1
}
# 使用者設定::通常
function Setting_User {
    # 去除捷徑字樣
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer" /v link /t REG_BINARY /d 00000000 /f
    # 檔案管理員預設打開(1本機 2快速存取)
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /t REG_DWORD /d 2 /f
    
    # 工作列設置成深色 (資料夾背景:AppsUseLightTheme, 工作列:SystemUsesLightTheme)
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v SystemUsesLightTheme /t REG_DWORD /d 0 /f
    # 工作列按鈕不要合併(0結合 1滿時結合 2不結合)
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarGlomLevel /t REG_DWORD /d 2 /f
    # 顯示副檔名
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f
    # 顯示隱藏檔案
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 0 /f
    # 顯示隱藏系統檔
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSuperHidden /t REG_DWORD /d 1 /f
    # 打開上一次登入時的資料夾
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v PersistBrowsers /t REG_DWORD /d 1 /f
    
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
    # if ((Get-Process -ProcessName:'explorer' -ErrorAction:SilentlyContinue)) { Stop-Process -ProcessName:'explorer' }

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
    
    # 關閉 Windwos 開機提示"讓我們完成你的電腦設定"的蓋板頁面
    reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d 0 /f
    reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310089Enabled" /t REG_DWORD /d 0 /f
    reg add "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsSpotlightWindowsWelcomeExperience" /t REG_DWORD /d 1 /f
    
    # 移除右鍵 使用skype共享 的選單
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\PackagedCom\Package\Microsoft.SkypeApp_15.103.3208.0_x64__kzf8qxf38zg5c\Class\{776DBC8D-7347-478C-8D71-791E12EF49D8}" /v "DllPath" /t REG_SZ /d "-Skype\SkypeContext.dll" /f
    
    # Win11設置
    if ([System.Environment]::OSVersion.Version.Build -ge 2200) {
        # 自動展開右鍵
        reg add "HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /t REG_SZ /f
        
        # 移除右下角 Copilot 標記
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarSd /t REG_DWORD /d 1 /f
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCopilotButton /t REG_DWORD /d 0 /f
        
        # 當我將視窗拖移到螢幕頂端時顯示貼齊版面配置
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v EnableSnapBar /t REG_DWORD /d 0 /f
        
        # 多工切換時顯示所有視窗 (預設值2:顯示3個最近使用的索引標籤, 3:不顯示索引標籤)
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "MultiTaskingAltTabFilter" /t REG_DWORD /d 3 /f
        
        # 在工作列上的搜尋方塊 (0:隱藏, 1:僅搜尋圖示, 2:搜尋圖示和標籤, 3:搜尋方塊)
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f
    }
    
    # 重新啟動explorer
    if ((Get-Process -ProcessName:'explorer' -ErrorAction:SilentlyContinue)) { Stop-Process -ProcessName:'explorer' }
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
    # 停用驅動更新模組
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v ExcludeWUDriversInQualityUpdate /t REG_DWORD /d 1 /f
    
    # Win11設置
    if ([System.Environment]::OSVersion.Version.Build -ge 2200) {
        # 停用Windows 11桌面右下方「不符合系統需求」浮水印
        reg add "HKEY_CURRENT_USER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d 0 /f
    }
    
    # 關閉 edge 桌面搜索條
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "WebWidgetAllowed" /t REG_DWORD /d 0 /f
    # 阻止 Edge 顯示「首次運行」歡迎頁面
    reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Edge" /v "HideFirstRunExperience" /t REG_DWORD /d 1 /f
    # 移除 Edge 右上角的Bing圖示
    reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Edge" /v "HubsSidebarEnabled" /t REG_DWORD /d 0 /f
    # 禁止Edge更新時在桌面建立捷徑
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v "CreateDesktopShortcutDefault" /t REG_DWORD /d 0 /f
    # 移除 Edge 未登錄狀態的紅點 (已失效的樣子)
    # reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "ExperimentationAndConfigurationServiceControl" /t REG_DWORD /d 0 /f
    
    # 系統設定
    Setting_System2
    # 清除PowerShell歷史紀錄
    Remove-Item (Get-PSReadlineOption).HistorySavePath -Force
}
function VM_Setting2 {
    # 虛擬機設定
    VM_Setting
    # 安裝軟體
    Set-ExecutionPolicy Bypass -S:Process -F; irm chocolatey.org/install.ps1|iex
    choco install -y 7zip
    choco install -y git --params "/NoShellIntegration"
    choco install -y vscode
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

# 啟用WindwosKMS授權
function WindowsActiveKMS {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory)]
        [string] $KmsHost,
        [string] $ProductKey
    )
    # 獲取序號
    if (!$ProductKey) {
        $Version = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").EditionID
        $KeyList = @{
            Core         = 'TX9XD-98N7V-6WMQ6-BX7FG-H8Q99'
            Professional = 'W269N-WFGWX-YVC9B-4J6C9-T83GX'
            Education    = 'NW6C2-QMPVW-D7KKK-3GKT6-VCFB2'
            Enterprise   = 'NPPR9-FWDCX-D2C8J-H872K-2YT43'
        }; $Key = $KeyList.$Version
    } else { $Key = $ProductKey }
    # 啟用Windwos
    if (!$Key) { Write-Host "此電腦的 Windows 版本不在清單內, 請使用 -ProductKey 輸入該版本對應的大量授權序號"; return } else {
        cscript -nologo c:\windows\system32\slmgr.vbs -ipk $Key
        cscript -nologo c:\windows\system32\slmgr.vbs -skms $KmsHost
        cscript -nologo c:\windows\system32\slmgr.vbs -ato
        cscript -nologo c:\windows\system32\slmgr.vbs -dli
    }
} # WindowsActiveKMS

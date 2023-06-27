各項 Windows 設定快捷總整理  
===

許願池可以到issues裡面提交  
https://github.com/hunandy14/WindowsReg/issues

<br><br>

# 系統
### WindowsUpdate

```ps1
# 恢復預設值
irm bit.ly/SetWinUpd|iex; Set-WinUpdate -Default

# 設定更新為手動(自動檢查)
irm bit.ly/SetWinUpd|iex; Set-WinUpdate -Manual

# 設定更新為不檢查
irm bit.ly/SetWinUpd|iex; Set-WinUpdate -NotCheck

# 關閉自動更新
irm bit.ly/SetWinUpd|iex; Set-WinUpdate -Stop

# 刪除已下載的緩存
irm bit.ly/SetWinUpd|iex; Remove-WinUpdateStorage
```

### WindowsDefenderAntivirus

```ps1
# 關閉即時掃描 (基本上就能避免 1. 砍你檔案 2. 阻擋執行非安全軟體)
irm bit.ly/SetWinDA|iex; Set-WinDefender DisableRealtimeMonitoring

# 完整關閉 WindowsDefender
irm bit.ly/SetWinDA|iex; Set-WinDefender DisableAntiSpyware

# 恢復程序對系統的變更
irm bit.ly/SetWinDA|iex; Set-WinDefender Revert

# 恢復所有防毒設定到原廠設定
irm bit.ly/SetWinDA|iex; Set-WinDefender RestoreDefault
```

### WindwosDriverUpdate
```ps1
# 禁用AMD顯示卡驅動更新
irm bit.ly/DisAMDUpdate|iex; DisableVideoDriverUpdate -Filter:Radeon

# 恢復所有設備的自動更新
irm bit.ly/DisAMDUpdate|iex; DisableVideoDriverUpdate -Recovery
```

### WindowsUpdate Version

```ps1
# 鎖定當前 Windows 版本
irm bit.ly/SetWinUpd|iex; LockWindowsVersion -Current

# 鎖定指定 Windows 版本
irm bit.ly/SetWinUpd|iex; LockWindowsVersion -Version:21H2

# 解除鎖定
irm bit.ly/SetWinUpd|iex; LockWindowsVersion -Unlock
```

```ps1
# 設定開發者測試通道
irm bit.ly/SetWinUpd|iex; OfflineInsiderEnroll
```

```ps1
# 解除升級 Windows11 限制
irm bit.ly/SkipTPM|iex
```

### InstantGo
```ps1
# 關閉現代待機
irm bit.ly/SetInstantGo|iex; InstantGo -Disable

# 開啟現代待機
irm bit.ly/SetInstantGo|iex; InstantGo -Enable

# 查看狀態
irm bit.ly/SetInstantGo|iex; InstantGo -Info
```

### Windows UAC
```ps1
# 不要把桌面變黑
irm bit.ly/SetWinUAC|iex; SetUAC -Set:1

# 關閉提醒
irm bit.ly/SetWinUAC|iex; SetUAC -Set:0

# 恢復預設
irm bit.ly/SetWinUAC|iex; SetUAC -Default

```

<br><br>

# 個人化設定
### Win11 右鍵自動展開
```ps1
# Win11 右鍵自動展開
irm bit.ly/3s9kWHO|iex; OnceRightClick -Once

# 復原
irm bit.ly/3s9kWHO|iex; OnceRightClick
```

<br><br>

# 其他
#### Install-Regjump
```ps1
irm bit.ly/3BkBukF|iex; Install-Regjump
```

<br>

### 家用版啟用群組原則(gpedit.msc)
```ps1
irm bit.ly/InstallGpedit|iex
```

<br>

### 不用輸入密碼自動登入Windows桌面
```ps1
irm bit.ly/3tkkqIn|iex; netplwiz
```

<br>

### 登入Windows自動亮燈
```ps1
irm bit.ly/39iuwmj|iex; InitialKeyboard -NumLock
```

<br>

### 家用版升級到專業版
```ps1
irm bit.ly/UpgradeWinPro|iex
```

<br>

### 獲取筆電OEM授權序號
```ps1
(Get-WmiObject SoftwareLicensingService).OA3xOriginalProductKey
```

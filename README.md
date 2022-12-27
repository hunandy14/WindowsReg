各項 Windows 設定快捷總整理  
===

許願池可以到issues裡面提交  
https://github.com/hunandy14/WindowsReg/issues

<br><br>

# 系統
### WindowsUpdate

```ps1
# 恢復預設值
irm bit.ly/StopWinUpdate|iex; StopWinUpdate -Default

# 設定更新為手動(自動檢查)
irm bit.ly/StopWinUpdate|iex; StopWinUpdate -Manual

# 設定更新為不檢查
irm bit.ly/StopWinUpdate|iex; StopWinUpdate -NotCheck

# 關閉自動更新
irm bit.ly/StopWinUpdate|iex; StopWinUpdate -Stop
```

### WindowsDefenderAntivirus

```ps1
# 完整關閉 WindowsDefender
irm bit.ly/3GACH9d|iex; WindowsDefenderAntivirus -Disable

# 關閉即時掃描 (基本上就能避免 1. 砍你檔案 2. 阻擋執行非安全軟體)
irm bit.ly/3GACH9d|iex; WindowsDefenderAntivirus -DisableRealtime

# 恢復預設
irm bit.ly/3GACH9d|iex; WindowsDefenderAntivirus
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
irm bit.ly/StopWinUpdate|iex; LockWindowsVersion -Current

# 鎖定指定 Windows 版本
irm bit.ly/StopWinUpdate|iex; LockWindowsVersion -Version:21H2

# 解除鎖定
irm bit.ly/StopWinUpdate|iex; LockWindowsVersion -Unlock
```

```ps1
# 解除升級 Windows11 限制
irm bit.ly/StopWinUpdate|iex; Win11_Update -Unlock

# 還原升級 Windows11 限制
irm bit.ly/StopWinUpdate|iex; Win11_Update -Recovery
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
irm bit.ly/3Gca80R|iex; SetUAC -Set:1

# 關閉提醒
irm bit.ly/3Gca80R|iex; SetUAC -Set:0

# 恢復預設
irm bit.ly/3Gca80R|iex; SetUAC -Default

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

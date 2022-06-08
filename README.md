各項 Windows 設定快捷總整理  
===

許願池可以到issues裡面提交  
https://github.com/hunandy14/WindowsReg/issues

<br><br>

# 系統
#### WindowsUpdate

```
# 改為手動
irm bit.ly/3GAuGRF|iex; AutomaticUpdates -Manual

# 停用更新
irm bit.ly/3GAuGRF|iex; AutomaticUpdates -Stop

# 恢復預設
irm bit.ly/3GAuGRF|iex; AutomaticUpdates
```

```
# 鎖定當前 Windows 版本
irm bit.ly/3GAuGRF|iex; LockWindowsVersion -Current

# 鎖定指定 Windows 版本
irm bit.ly/3GAuGRF|iex; LockWindowsVersion -Version:21H2

# 解除鎖定
irm bit.ly/3GAuGRF|iex; LockWindowsVersion -Unlock
```

```
# 解除升級 Windows11 限制
irm bit.ly/3GAuGRF|iex; Win11_Update -Unlock

# 還原升級 Windows11 限制
irm bit.ly/3GAuGRF|iex; Win11_Update -Recovery
```

```
# 關閉現代待機
irm bit.ly/3JiAEaA|iex; InstantGo -Disable

# 開啟現代待機
irm bit.ly/3JiAEaA|iex; InstantGo -Enable

# 查看狀態
irm bit.ly/3JiAEaA|iex; InstantGo -Info
```

#### WindowsDefenderAntivirus

```
# 完整關閉 WindowsDefender
irm bit.ly/3GACH9d|iex; WindowsDefenderAntivirus -Disable

# 關閉即時掃描 (基本上就能避免 1. 砍你檔案 2. 阻擋執行非安全軟體)
irm bit.ly/3GACH9d|iex; WindowsDefenderAntivirus -DisableRealtime

# 恢復預設
irm bit.ly/3GACH9d|iex; WindowsDefenderAntivirus

```

#### Windows UAC
```
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
```
# Win11 右鍵自動展開
irm bit.ly/3s9kWHO|iex; OnceRightClick -Once

# 復原
irm bit.ly/3s9kWHO|iex; OnceRightClick
```

<br><br>

# 其他
#### Install-Regjump
```
irm bit.ly/3BkBukF|iex; Install-Regjump
```

#### EdgeMediaControls
提示：工作列的圖示可能需要重新釘選  

```
# 將設定值的捷徑覆蓋到桌面及開始選單的 EDGE
irm bit.ly/3IeentX|iex; EdgeMediaControls -Desktop -Start

```

### DeviceDriverUpdate
禁止微軟更新特定裝置的驅動程式  

```
# 禁止微軟自動更新 NVIDI 和 AMD 設備的驅動程式
irm bit.ly/3IgtUJU|iex; DeviceDriverUpdate -Name:"AMD|NVIDIA"

# 恢復所有設備自動更新
irm bit.ly/3IgtUJU|iex; DeviceDriverUpdate
```

### 家用版啟用群組原則(gpedit.msc)
```
irm bit.ly/35EVGlc|iex; GpeditEbable
```

### 不用輸入密碼自動登入Windows桌面
```
irm bit.ly/3tkkqIn|iex; netplwiz
```
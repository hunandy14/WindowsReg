各項 Windows 設定快捷總整理
===

#### WindowsUpdate

```
# 改為手動
irm bit.ly/3GAuGRF|iex; AutomaticUpdates -Manual

# 恢復預設
irm bit.ly/3GAuGRF|iex; AutomaticUpdates
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

#### Install-Regjump


#### EdgeMediaControls
1. 輸入之後會重新打開一次，記得先儲存網頁才按下Enter。
2. 視窗重啟之後會失效，要從桌面捷徑打開。
3. 解決把捷徑存到啟動內每次開機自動開啟，開了就別關了一直掛著就好。

```
# 1 重起當前視窗並載入設定
irm bit.ly/3IeentX|iex; EdgeMediaControls 

# 2 將設定值的捷徑儲存到桌面 (包含1)
irm bit.ly/3IeentX|iex; EdgeMediaControls -Desktop

# 3 將設定值的捷徑儲存到啟動 (包含1)
irm bit.ly/3IeentX|iex; EdgeMediaControls -Start

```
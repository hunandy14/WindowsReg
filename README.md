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
提示：工作列的圖示可能需要重新釘選

```
# 將設定值的捷徑覆蓋到桌面及開始選單的 EDGE
irm bit.ly/3IeentX|iex; EdgeMediaControls -Desktop -Start

```
Windows更新相關設置
===

快速使用 (設定更新為手動)
```ps1
irm bit.ly/StopWinUpdate|iex; StopWinUpdate -Manual
```


## 設定 Windows 自動更新為 手動或關閉
![](img/UpdateManual.png)

```ps1
# 設定更新為手動
irm bit.ly/StopWinUpdate|iex; AutomaticUpdates -Manual

# 關閉自動更新
irm bit.ly/StopWinUpdate|iex; AutomaticUpdates -Stop

# 恢復自動更新
irm bit.ly/StopWinUpdate|iex; AutomaticUpdates

```


## 設定 Windows 自動更新 Ver2.0

```ps1
# 恢復預設值
irm bit.ly/StopWinUpdate|iex; StopWinUpdate -Default

# 設定更新為手動
irm bit.ly/StopWinUpdate|iex; StopWinUpdate -Manual

# 關閉自動更新
irm bit.ly/StopWinUpdate|iex; StopWinUpdate -Stop

# 設置更新為不檢查 (測試中可能無效)
irm bit.ly/StopWinUpdate|iex; StopWinUpdate -NotCheck

```

## 鎖定 Windows 版本
![](img/Cover.png)

```ps1
# 鎖定當前 Windows 版本
irm bit.ly/StopWinUpdate|iex; LockWindowsVersion -Current

# 指定 Windows 版本
irm bit.ly/StopWinUpdate|iex; LockWindowsVersion -Version:21H2

# 復原解鎖(之後想更新的話)
irm bit.ly/StopWinUpdate|iex; LockWindowsVersion -Unlock

```

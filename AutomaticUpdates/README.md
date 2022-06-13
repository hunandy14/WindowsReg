Windows更新相關設置
===

## 設定 Windows 自動更新為 手動或關閉
![](img/UpdateManual.png)

```ps1
# 設定更新為手動
irm bit.ly/3GAuGRF|iex; AutomaticUpdates -Manual

# 關閉自動更新
irm bit.ly/3GAuGRF|iex; AutomaticUpdates -Stop

# 恢復自動更新
irm bit.ly/3GAuGRF|iex; AutomaticUpdates
```


## 鎖定 Windows 版本
![](img/Cover.png)

```ps1
# 鎖定當前 Windows 版本
irm bit.ly/3GAuGRF|iex; LockWindowsVersion -Current

# 指定 Windows 版本
irm bit.ly/3GAuGRF|iex; LockWindowsVersion -Version:21H2

# 復原解鎖(之後想更新的話)
irm bit.ly/3GAuGRF|iex; LockWindowsVersion -Unlock
```

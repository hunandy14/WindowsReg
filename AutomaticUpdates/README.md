Windows更新相關設置
===

快速使用 (設定更新為手動)
```ps1
irm bit.ly/StopWinUpdate|iex; StopWinUpdate -Manual
```

![](img/UpdateManual.png)

<br><br><br>

## 設定 Windows 自動更新

```ps1
# 恢復預設值
irm bit.ly/StopWinUpdate|iex; StopWinUpdate -Default

# 設定更新為手動
irm bit.ly/StopWinUpdate|iex; StopWinUpdate -Manual

# 關閉自動更新
irm bit.ly/StopWinUpdate|iex; StopWinUpdate -Stop

# 設置更新為不檢查
irm bit.ly/StopWinUpdate|iex; StopWinUpdate -NotCheck

```

> `手動` 與 `不檢查` 的區別是服務不會定期被啟動，就不會在右下角出現黃色驚嘆號了  
> 有個例外是打開設定中的更新頁面，單單只是打開並沒有按檢查也會觸發服務啟動然後檢查更新  
> 還有一個是太長時間都檢查的話，會冒出紅色驚嘆要求更新



<br><br><br>

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

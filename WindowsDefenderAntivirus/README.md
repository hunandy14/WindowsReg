關閉WindowsDefenderAntivirus
===

快速使用(關閉即時掃描)
```ps1
irm bit.ly/SetWinDA|iex; Set-WinDefender DisableRealtimeMonitoring
```

執行完記得依照說明手動關閉防竄改保護 (參照文末有圖文說明)

![](img/Cover.png)

<br>

詳細說明
```ps1
# 關閉即時掃描 (基本上就能避免 1. 砍你檔案 2. 阻擋執行非安全軟體)
irm bit.ly/SetWinDA|iex; Set-WinDefender DisableRealtimeMonitoring

# 完整關閉 WindowsDefender (該原則在Win2004以上重啟後會被復原)
irm bit.ly/SetWinDA|iex; Set-WinDefender DisableAntiSpyware

# 恢復程序對系統的變更
irm bit.ly/SetWinDA|iex; Set-WinDefender Revert

# 恢復所有防毒設定到原廠設定
irm bit.ly/SetWinDA|iex; Set-WinDefender RestoreDefault
```

> 微軟在 Win2004 版已棄用 `完整關閉 WindowsDefender` 的原則  
> 雖然還是可以關閉但是是一次性的, 關閉後過一段時間原則會被復原  
> 雖然原則會被復原但 WindowsDefender 還是會保持關閉狀態, 直到重新啟動後才恢復  



<br><br><br>

## 關閉防竄改保護的設置方法
1. 程序執行完會自動打開WindowsDefenderAntivirus
(如果不小心關掉了照著說明重新點出來就好)

2. 依照圖片操作將防竄改保護關閉
![](img/Step1.png)

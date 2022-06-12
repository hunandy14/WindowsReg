筆電降溫，關閉CPU自動超頻
===

複製當前方案並將其關閉自超頻
```ps1
irm bit.ly/3MHZKkz|iex; Set-PerfBoost -Value:0 -GUID:(CopyScheme "電池保護") -Apply
```

複製其他預設方案
```ps1
irm bit.ly/3MHZKkz|iex; Set-PerfBoost -Value:0 -GUID:(CopyScheme $Powercfg_PowerSaver "電池保護") -Apply
irm bit.ly/3MHZKkz|iex; Set-PerfBoost -Value:0 -GUID:(CopyScheme $Powercfg_Balanced "電池保護") -Apply
irm bit.ly/3MHZKkz|iex; Set-PerfBoost -Value:0 -GUID:(CopyScheme $Powercfg_HighPerformance "電池保護") -Apply
```

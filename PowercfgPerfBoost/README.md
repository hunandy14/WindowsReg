筆電降溫，關閉CPU自動超頻
===

![](img/Cover.png)

關閉當前方案的自動超頻
```ps1
irm bit.ly/PerfBoost|iex; Set-PerfBoost 0 -Apply
```

複製當前方案並關閉自超頻
```ps1
irm bit.ly/PerfBoost|iex; Set-PerfBoost 0 (CopyScheme "關閉睿頻") -Apply
```

複製預設方案並關閉自超頻
```ps1
irm bit.ly/PerfBoost|iex; Set-PerfBoost -Value:0 -GUID:(CopyScheme "關閉睿頻" $Powercfg_PowerSaver) -Apply
irm bit.ly/PerfBoost|iex; Set-PerfBoost -Value:0 -GUID:(CopyScheme "關閉睿頻" $Powercfg_Balanced) -Apply
irm bit.ly/PerfBoost|iex; Set-PerfBoost -Value:0 -GUID:(CopyScheme "關閉睿頻" $Powercfg_HighPerformance) -Apply
```

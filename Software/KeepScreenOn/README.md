保持螢幕亮著
===

快速使用1 (滑鼠抖動)
```ps1
irm bit.ly/KeepScrOn|iex; KeepScrOn
```

快速使用2 (Num鍵抖動)
```ps1
irm bit.ly/KeepScrOn|iex; KeepScrOn2
```




Bat檔案 或 新增捷徑
```ps1
## 線上
PowerShell -NoP "irm bit.ly/KeepScrOn|iex; KeepScrOn -Time:59"
## 線下 (這裡ps1檔案只能放絕對路徑)
PowerShell -NoP -EX bypass ".'D:\KeepScreenOn.ps1'; KeepScrOn -Time:59"
```

移動屬標測試
```ps1
irm bit.ly/KeepScrOn|iex; KeepScrOn 3 -Debug
```

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




捷徑使用(新增捷徑之後這行打進去)
```ps1
powershell -NoExit -C "&{irm bit.ly/KeepScrOn|iex; KeepScrOn}"
```

移動屬標測試
```ps1
irm bit.ly/KeepScrOn|iex; KeepScrOn 3 -Debug
```

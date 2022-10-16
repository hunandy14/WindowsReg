保持螢幕亮著
===

## 快速使用1 (滑鼠抖動)
```ps1
irm bit.ly/KeepScrOn|iex; KeepScrOn
```

## 快速使用2 (Num鍵抖動)
```ps1
irm bit.ly/KeepScrOn|iex; KeepScrOn2
```



<br><br><br>

## 其他
移動屬標測試
```ps1
irm bit.ly/KeepScrOn|iex; KeepScrOn 3 -Debug
```


## Bat檔案 或 新增捷徑
線上
```ps1
PowerShell -NoP -C "irm bit.ly/KeepScrOn|iex; KeepScrOn -Time:59"
```

線下 (這裡ps1檔案只能放絕對路徑)
```ps1
PowerShell -NoP -EX bypass -C ".'D:\KeepScreenOn.ps1'; KeepScrOn -Time:59"
```



<br><br><br>

## 安裝
```ps
irm bit.ly/KeepScrOn|iex; Install-App
```

- 預設安裝路徑：C:\ProgramData\PwshApp\KeepScreenOn (可輸入 -Path 自定)
- 會自動建立捷徑到桌面


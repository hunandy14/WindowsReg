應用程式dpi縮放設定
===

快速使用
```PS1
irm bit.ly/DpiOverride|iex; Set-DpiOverride "FilePath.exe"
```

預設會將該路徑的檔案設定成不會縮放，可以解決某些傳統應用程式縮放之後UI跑掉或是模糊的問題。

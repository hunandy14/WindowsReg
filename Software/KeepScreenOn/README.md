保持螢幕亮著
===

快速使用
```ps1
irm bit.ly/KeepScrOn|iex; KeepScrOn
```

捷徑使用(新增捷徑之後這行打進去)
```ps1
powershell -NoExit -C "&{irm bit.ly/KeepScrOn|iex; KeepScrOn}"
```


移動屬標測試
```ps1
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$Pos = [System.Windows.Forms.Cursor]::Position
$Offset = 100
[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point((($Pos.X)+$Offset), $Pos.Y)
```
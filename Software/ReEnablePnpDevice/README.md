重啟用 Intel 內顯裝置
===

命令啟動
```
irm bit.ly/3Ik0iMl|iex; ReEnablePnpDevice -IntelDisplay
```

捷徑啟動
```
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -command "$PnpDevice = (Get-PnpDevice -FriendlyName:'Intel(R) UHD Graphics'); $PnpDevice|Disable-PnpDevice -confirm:$false; $PnpDevice|Enable-PnpDevice -confirm:$false"
```
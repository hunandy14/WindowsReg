使用者帳戶控制設定工具
===

快速設定
```ps1
irm bit.ly/SetWinUAC|iex; SetUAC -Set:1
```

詳細說明
```ps1
# 系統預設值
irm bit.ly/SetWinUAC|iex; SetUAC -Default

# 一律通知我
irm bit.ly/SetWinUAC|iex; SetUAC -Set:3
# 只在應用程式嘗試變更我的電腦時才通知我(預設值)
irm bit.ly/SetWinUAC|iex; SetUAC -Set:2
# 應用程式嘗試變更我的電腦時才通知我(不要將桌面變暗)
irm bit.ly/SetWinUAC|iex; SetUAC -Set:1
# 不要通知我
irm bit.ly/SetWinUAC|iex; SetUAC -Set:0
```

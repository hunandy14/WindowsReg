登入檔設定工具
===

### 新增登錄檔
載入函式
```ps1
irm raw.githubusercontent.com/hunandy14/WindowsReg/master/RegUnitily/RegUnitily.ps1|iex
```

範例
```ps1
function RegUnitily {
    # 新增 netplwiz 可自動登入的選項
    $regPath  = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device"
    $regItem  = "DevicePasswordLessBuildVersion"
    $regType  = "REG_DWORD"
    $regValue = 0
    
    # 登陸
    irm bit.ly/3Nxp11X|iex; RegAdd $regPath $regItem $regType $RegValue
    # 僅輸出命令
    irm bit.ly/3Nxp11X|iex; RegAdd $regPath $regItem $regType $RegValue -OnlyOutCmd
} RegUnitily
```

刪除
```ps1
function RegUnitily {
    $regPath  = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $regItem  = "NoAutoUpdate"
    $regType  = "REG_DWORD"
    $regValue = 0
    irm bit.ly/3Nxp11X|iex; RegAdd $regPath $regItem $regType $RegValue -OnlyOutCmd 
    irm bit.ly/3Nxp11X|iex; RegDel $regPath $regItem -OnlyOutCmd
} RegUnitily
```

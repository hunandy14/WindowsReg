登入檔設定工具
===

### 新增登錄檔
載入函式
```ps1
irm raw.githubusercontent.com/hunandy14/WindowsReg/master/RegUnitily/RegUnitily.ps1|iex
```

範例
```ps1
$regPath  = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device"
$regItem  = "DevicePasswordLessBuildVersion"
$regType  = "REG_DWORD"
$regValue = 0
irm bit.ly/3Nxp11X|iex; RegAdd $regPath $regItem $regType $RegValue
```

輸出命令
```ps1
function RegUnitily {
    $regPath  = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device"
    $regItem  = "DevicePasswordLessBuildVersion"
    $regType  = "REG_DWORD"
    $regValue = 0
    irm bit.ly/3Nxp11X|iex; RegAdd -OnlyOutCmd $regPath $regItem $regType $RegValue
} RegUnitily
```
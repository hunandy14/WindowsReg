登入檔設定工具
===

### 載入函式庫
```ps1
irm raw.githubusercontent.com/hunandy14/WindowsReg/master/RegUnitily/RegUnitily.ps1|iex
```

```ps1
irm bit.ly/3Nxp11X|iex
```

### 範例1
```ps1
function RegUnitily {
    # 自動更新選項設置為手動
    $regPath  = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $regItem  = "AUOptions"
    $regType  = "REG_DWORD"
    $regValue = 2
    # 新增 (-OnlyOutCmd僅輸出不會執行)
    irm bit.ly/3Nxp11X|iex; RegAdd $regPath $regItem $regType $RegValue -OnlyOutCmd
    # 刪除 (-OnlyOutCmd僅輸出不會執行)
    irm bit.ly/3Nxp11X|iex; RegDel $regPath $regItem -OnlyOutCmd
} RegUnitily
```

### 範例2 (預設值)
新增
```ps1
function RegUnitily {
    # Windows11 右鍵自動展開
    $regPath  = "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
    $regValue = ''
    # 新增 (-OnlyOutCmd僅輸出不會執行)
    irm bit.ly/3Nxp11X|iex; RegAdd $regPath -DefaultItem $regValue -OnlyOutCmd
    # 刪除 (-OnlyOutCmd僅輸出不會執行)
    irm bit.ly/3Nxp11X|iex; RegDel $regPath -DefaultItem -OnlyOutCmd
} RegUnitily
```

###################################################################################################
# InitialKeyboardIndicators 數值含義：
    # 0: 關閉全部鎖定
    # 1: 單獨開啟大寫鎖定Caps Lock
    # 2: 單獨開啟數字鎖定Num Lock
    # 3: 開啟大寫和數字鎖定
    # 4: 單獨開啟滾動鎖定ScrollLock
    # 5: 開啟大寫和滾動鎖定
    # 6: 開啟數字和滾動鎖定
    # 7: 開啟全部鎖定
###################################################################################################
function InitialKeyboard {
    param (
        [int64] $Value = 0,
        [switch] $NumLock,
        [switch] $CapsLock,
        [switch] $ScrollLock
    )
    if ($CapsLock  ) { $Value=$Value+1 }
    if ($NumLock   ) { $Value=$Value+2 }
    if ($ScrollLock) { $Value=$Value+4 }
    $UserSID  = (Get-LocalUser -Name:$env:USERNAME).sid.value
    reg add "HKEY_USERS\$UserSID\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d $Value /f
} # InitialKeyboard -NumLock

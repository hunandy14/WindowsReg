function ExploreReflash {
    reg add "HKEY_CLASSES_ROOT\WOW6432Node\CLSID\{BDEADE7F-C265-11D0-BCED-00A0C90AB50F}\Instance" /v dontrefresh /t REG_DWORD /d 00000000 /f
} ExploreReflash

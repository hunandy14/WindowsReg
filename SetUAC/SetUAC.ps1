# 使用者帳戶控制設定工具
function SetUAC {
    param (
        [Parameter(Position = 0, ParameterSetName = "Set", Mandatory)]
        [ValidateSet( '0', '1', '2', '3' )]
        [string] $Set,
        [Parameter(ParameterSetName = "Default")]
        [switch] $Default
    )
    # 預設值
    if ($Default) { $Set = "2" }
    # 設置
    if ($Set -eq "3") {     # 一律通知我
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 00000002 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 00000001 /f
    }
    elseif ($Set -eq "2") { # 只在應用程式嘗試變更我的電腦時才通知我(預設值)
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 00000005 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 00000001 /f
    }
    elseif ($Set -eq "1") { # 應用程式嘗試變更我的電腦時才通知我(不要將桌面變暗)
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 00000005 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 00000000 /f
    }
    elseif ($Set -eq "0") { # 不要通知我
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 00000000 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 00000000 /f
    }
} # SetUAC -Set:1

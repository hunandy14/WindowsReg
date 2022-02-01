function SetUAC {
    param (
        [Parameter(Position = 0, ParameterSetName = "Default", Mandatory=$true)]
        [switch] $Default,
        [Parameter(Position = 0, ParameterSetName = "Set", Mandatory=$true)]
        [string] $Set
    )
    if ($Default) { $Set = "2" }
    
    if ($Set -eq "3") {
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 00000002 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 00000001 /f
    }
    elseif ($Set -eq "2") {
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 00000005 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 00000001 /f
    }
    elseif ($Set -eq "1") {
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 00000005 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 00000000 /f
    }
    elseif ($Set -eq "0") {
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 00000000 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 00000000 /f
    }
} # SetUAC -Set:1
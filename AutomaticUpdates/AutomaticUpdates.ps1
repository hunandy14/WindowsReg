function AutomaticUpdates {
    param(
        [switch] $Manual,
        [switch] $Stop,
        [switch] $ServiceInfo
    )
    if ($Manual) { # 將自動更新設置為手動
        AutomaticUpdates
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v NoAutoUpdate /t REG_DWORD /d 00000000 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v AUOptions /t REG_DWORD /d 00000002 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v ScheduledInstallDay /t REG_DWORD /d 00000000 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v ScheduledInstallTime /t REG_DWORD /d 00000003 /f
        reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v ScheduledInstallEveryWeek /t REG_DWORD /d 00000001 /f
    } elseif ($Stop) {
        if (Test-Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate") {
            reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f
        }
        # reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU /v NoAutoUpdate /t REG_DWORD /d 00000001 /f
        if ((Get-Service -Name:wuauserv).Status -eq "Running") { net stop wuauserv }
        (Get-Service -Name:wuauserv)|Set-Service -StartupType:disabled
        (Get-Service -Name:wuauserv)|Select-Object Name,DisplayName,Status,StartType
    }
    else { # 恢復為未設定狀態
        if (Test-Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate") {
            reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f
        }
        (Get-Service -Name:wuauserv)|Set-Service -StartupType:Automatic
        if ((Get-Service -Name:wuauserv).Status -eq "Stopped") { net start wuauserv }
    }
    # 查看目前服務的狀態
    if ($ServiceInfo) {
        (Get-Service -Name:wuauserv)|Select-Object Name,DisplayName,Status,StartType
    }
}

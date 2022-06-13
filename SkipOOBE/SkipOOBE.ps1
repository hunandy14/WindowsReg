function SkipOOBE {
    param (
        [String] $UserName
    )
    # 檢測
    if (!$UserName) { $UserName = 'User' }
    # 新增使用者
    New-LocalUser -Name:$UserName -Password:(New-Object System.Security.SecureString) | Out-Null
    Add-LocalGroupMember Users $UserName
    Add-LocalGroupMember Administrators $UserName
    # 略過OOBE
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\setup" /v 'OOBEInProgress' /t REG_DWORD /d 0 /f
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\setup" /v 'SetupPhase' /t REG_DWORD /d 0 /f
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\setup" /v 'SetupSupported' /t REG_DWORD /d 0 /f
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\setup" /v 'SetupType' /t REG_DWORD /d 0 /f
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\setup" /v 'SystemSetupInProgress' /t REG_DWORD /d 0 /f
    # 開啟超級使用者
    net user administrator /active:yes
    # 啟動後關閉
    $RunOnecePath = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    reg add $RunOnecePath /v 'run1' /t 'REG_SZ' /d "cmd.exe /c net user administrator /active:no" /f
    reg add $RunOnecePath /v 'run2' /t 'REG_SZ' /d "shutdown /r /t 1" /f
    # 重新啟動
    shutdown.exe /r /t 0
    # 提示
    Write-Host "正在重新啟動系統..."
} # SkipOOBE

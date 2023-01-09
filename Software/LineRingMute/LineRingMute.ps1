# Line鈴聲靜音
function LineRingMute {
    param (
        [switch] $Enable,
        [switch] $Disable
    )
    # 檔案
    $MuteRing = "https://github.com/hunandy14/WindowsReg/raw/master/Software/LineRingMute/wav/VoipRing.wav"
    $File = "C:$($env:HOMEPATH)\AppData\Local\LineCall\Data\sound\VoipRing.wav"
    # 設定權限
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$($env:UserName)","Write","Deny")
    $ACL = Get-ACL $File
    if ($Enable) { 
        # 撤銷權限
        $ACL.RemoveAccessRule($AccessRule)|Out-Null; $ACL|Set-Acl $File
        Set-ItemProperty $File IsReadOnly $false
        # 拒絕寫入
        Invoke-WebRequest $MuteRing -OutFile:$File
        Set-ItemProperty $File IsReadOnly $true
        $ACL.SetAccessRule($AccessRule)|Out-Null; $ACL|Set-Acl $File
        Write-Host "已將Line鈴聲設置為靜音"
    } elseif ($Disable) {
        # 撤銷權限
        $ACL.RemoveAccessRule($AccessRule)|Out-Null; $ACL|Set-Acl $File
        Set-ItemProperty $File IsReadOnly $false
        Write-Host "已將Line鈴聲恢復為預設"
    }
    # 確認
    # Write-Host $File
    # (Get-ACL $File).Access|Format-Table IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -AutoSize
} # LineRingMute -Enable



# Line自動更新
function LineUpdate {
    param (
        [switch] $Enable,
        [switch] $Disable
    )
    # 檔案
    $File = "C:$($env:HOMEPATH)\AppData\Local\LINE\bin\LineUpdater.exe"
    if ($Disable) {
        # 建立空白檔案
        Set-ItemProperty $File Attributes "Normal" -Force
        New-Item -ItemType:File $File -Force |Out-Null
        # 設置唯讀與隱藏
        Set-ItemProperty $File Attributes "Readonly,Hidden" -Force
        Write-Host "已停用Line自動更新"
    } elseif ($Enable) {
        # 解除唯讀
        Set-ItemProperty $File Attributes "Normal,Hidden" -Force
        Write-Host "已恢復Line自動更新"
    }
} # LineUpdate -Disable

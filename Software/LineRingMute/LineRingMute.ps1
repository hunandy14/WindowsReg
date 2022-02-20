function LineRingMute {
    param (
        [switch] $Enable,
        [switch] $Disable
    )
    # 檔案
    $MuteRing = "https://github.com/hunandy14/WindowsReg/raw/master/Software/LineRingMute/wav/VoipRing.wav"
    $File = "$($env:HOMEPATH)\AppData\Local\LineCall\Data\sound\VoipRing.wav"
    # 設定權限
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$($env:UserName)","Write","Deny")
    $ACL = Get-ACL $File
    if ($Enable) { 
        # 撤銷權限
        $ACL.RemoveAccessRule($AccessRule); $ACL|Set-Acl $File
        Set-ItemProperty $File IsReadOnly $false
        # 拒絕寫入
        Invoke-WebRequest $MuteRing -OutFile:$File
        Set-ItemProperty $File IsReadOnly $true
        $ACL.SetAccessRule($AccessRule); $ACL|Set-Acl $File
    } elseif ($Disable) {
        # 撤銷權限
        $ACL.RemoveAccessRule($AccessRule); $ACL|Set-Acl $File
        Set-ItemProperty $File IsReadOnly $false
    }
    # 確認
    (Get-ACL $File).Access|Format-Table IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -AutoSize
} # LineRingMute -Enable
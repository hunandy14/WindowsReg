function LineRingMute {
    param (
        [switch] $Enable,
        [switch] $Disable
    )
    # 目標檔案
    $File = "%userprofile%\AppData\Local\LineCall\Data\sound\VoipRing.wav"
    # 設定權限
    if ($Enable) {
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("hunan","Write","Deny")
    } elseif ($Disable) {
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("hunan","Write","Deny")
    }
    # 變更檔檔案權限
    $ACL = Get-ACL $File
    $ACL.RemoveAccessRule($AccessRule)
    $ACL | Set-Acl $File
    # 確認
    (Get-ACL $File).Access | Format-Table IdentityReference,FileSystemRights,AccessControlType,IsInherited,InheritanceFlags -AutoSize
}
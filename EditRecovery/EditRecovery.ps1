
# 獲取RE分區
function GetRecoveryPartition {
    if (((reagentc /info)[3]).IndexOf('Enabled') -eq -1) {
        Write-Host "RE分區尚未啟用" -ForegroundColor:Yellow
        return
    }
    $RecoveryPath = ((reagentc /info)[4])
    $DiskNum = (([regex]('\\harddisk([0-9]+)\\')).Matches($RecoveryPath)).Groups[1].Value
    $PartNum = (([regex]('\\partition([0-9]+)\\')).Matches($RecoveryPath)).Groups[1].Value
    return @($DiskNum, $PartNum)
} # GetRecoveryPartition

# 格式化容量單位
function FormatCapacity {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory=$false)]
        [double] $Capacity=0,
        [Parameter(Position = 1, ParameterSetName = "", Mandatory=$false)]
        [double] $Digit=1
    )
    $Unit = 'Byte'
    if (([Math]::Floor($Capacity)|Measure-Object -Character).Characters -gt 3) {
        $Capacity = $Capacity/1024.0; $Unit = 'KB'
    } if (([Math]::Floor($Capacity)|Measure-Object -Character).Characters -gt 3) {
        $Capacity = $Capacity/1024.0; $Unit = 'MB'
    } if (([Math]::Floor($Capacity)|Measure-Object -Character).Characters -gt 3) {
        $Capacity = $Capacity/1024.0; $Unit = 'GB'
    } if (([Math]::Floor($Capacity)|Measure-Object -Character).Characters -gt 3) {
        $Capacity = $Capacity/1024.0; $Unit = 'TB'
    } if (([Math]::Floor($Capacity)|Measure-Object -Character).Characters -gt 3) {
        $Capacity = $Capacity/1024.0; $Unit = 'PB'
    } $Capacity = [Math]::Round($Capacity, $Digit)
    return "$Capacity $Unit"
} # FormatCapacity

# RE系統相關設定
function EditRecovery {
    [CmdletBinding(DefaultParameterSetName = "Enable")]
    param (
        [Parameter(Position = 0, ParameterSetName = "Info")]
        [switch] $Info,
        [Parameter(Position = 0, ParameterSetName = "Remove")]
        [switch] $Remove,
        [Parameter(Position = 0, ParameterSetName = "Disable")]
        [switch] $Disable,
        [Parameter(Position = 0, ParameterSetName = "Enable")]
        [Parameter(Position = 1, ParameterSetName = "Remove")]
        [switch] $Enable,
        [Parameter(Position = 0, ParameterSetName = "SetReImgPath")]
        [switch] $SetReImg,
        [Parameter(Position = 1, ParameterSetName = "SetReImgPath")]
        [string] $ImgPath
    )
    # 顯示當前狀態
    if ($Info) {
        reagentc /info
    } else {
        # 關閉RE分區
        if ($Disable) {
            reagentc /disable
        }
        # 刪除RE分區
        if ($Remove) {
            # 獲取RE分區位置
            $Posi = (GetRecoveryPartition)
            $DN = $Posi[0]
            $PN = $Posi[1]
            if (!$Posi) { return }
            $Part = (Get-Partition -Number:$PN)[$DN]
            $Capacity = FormatCapacity($Part.Size)
            # 刪除RE分區(警告)
            Write-Host "即將刪除 [" -NoNewline
            Write-Host "磁碟:$($DN), 分區:$($PN), 容量:$Capacity" -ForegroundColor:Yellow -NoNewline
            Write-Host "] 的RE分區, " -NoNewline
            Write-Host "刪除後無法復原" -ForegroundColor:Red -NoNewline
            Write-Host "請確保分區位置是正確的"
            if (!$Force) {
                $response = Read-Host "  沒有異議請輸入Y (Y/N) ";
                if ($response -ne "Y" -or $response -ne "Y") { Write-Host "使用者中斷" -ForegroundColor:Red; return; }
            }
            # 關閉RE分區
            reagentc /disable
            # 移除RE分區
            $Part|Remove-Partition
            # 合併釋放的空間到前一個分區
            $PartPre = (Get-Partition -Number:($PN-1))[$DN]
            $PartPre|Resize-Partition -Size:($PartPre|Get-PartitionSupportedSize).SizeMax
        }
        # 重啟RE分區
        if ($Enable) {
            reagentc /enable
        }
        # 設定路徑
        if ($SetReImg) {
            $Path='C:\windows\system32\recovery'
            if ($ImgPath) {
                if (!((Test-Path -PathType:Leaf $ImgPath) -and ((Get-Item $ImgPath).Name -eq 'Winre.wim'))) {
                    Write-Host "[錯誤]::輸入的檔案(檔名)不是 " -NoNewline
                    Write-Host "Winre.wim" -ForegroundColor:Yellow -NoNewline
                    Write-Host " 檔案"
                    return
                }
                Copy-Item $ImgPath $Path
            }
            reagentc /setreimage /path $Path
            reagentc /enable
        }
    }
}
# EditRecovery -SetReImg
# EditRecovery -Enable
# EditRecovery -Disable
# EditRecovery -Remove -Enable


# 獲取RE分區
function Get-RecoveryPartition {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param (
        [Parameter(Position = 0, ParameterSetName = "Default")]
        [String] $DriveLetter,
        [Parameter(ParameterSetName = "CurrentlyUsed")]
        [switch] $CurrentlyUsed
    )
    # 指定磁碟機中所有RE分區
    if ($DriveLetter) {
        $Dri = Get-Partition -DriveLetter $DriveLetter -EA 0
        if ($Dri) {
            return $Dri |Get-Disk|Get-Partition |Where-Object{ # ((GPT修復分區 -or MBR修復分區) -and 空磁碟標籤)
                (($_.Type -eq 'Recovery') -or ($_.MbrType -eq 39)) -and ((($_|Get-Volume).FileSystemLabel) -eq "")
            }
        } else { return $Null }
    } else { $CurrentlyUsed = $true }
    # 當前系統使用中的RE分區
    if ($CurrentlyUsed) {
        # 確認啟用狀態
        $RecoveryPath = [string]((reagentc /info) -match("\\\\\?\\GLOBALROOT\\device"))
        if ($RecoveryPath -eq '') {
            Write-Host "RE分區尚未啟用, 嘗試啟用中... " -NoNewline
            (reagentc /enable) |Out-Null; (reagentc /enable) |Out-Null
            # 重新確認啟用狀態
            $RecoveryPath = [string]((reagentc /info) -match("\\\\\?\\GLOBALROOT\\device"))
            if ($RecoveryPath -eq '') {
                Write-Error "無法啟用"; return
            } else { Write-Host "啟用成功" }
        }
        # 解析路徑並獲取分區物件
        $DiskNum = (([regex]('\\harddisk([0-9]+)\\')).Matches($RecoveryPath)).Groups[1].Value
        $PartNum = (([regex]('\\partition([0-9]+)\\')).Matches($RecoveryPath)).Groups[1].Value
        return Get-Partition -DiskNumber $DiskNum -PartitionNumber $PartNum
    }
} # Get-RecoveryPartition

# 格式化容量單位
function FormatCapacity {
    param (
        [Parameter(Position = 0, ParameterSetName = "")]
        [double] $Value = 0,
        [Parameter(Position = 1, ParameterSetName = "")]
        [double] $Digit = 1,
        [switch] $KB,

        [Parameter(ParameterSetName = "")]
        [uint64] $Width = 5,
        [switch] $Align
    )
    # 設定單位
    [string] $Unit_Type = 'Byte'
    [double] $Unit = 1024.0
    $UnitList = @('KB', 'MB', 'GB', 'TB', 'PB')
   
    # 開始換算
    foreach ($Item in $UnitList) {
        $bool = (([Math]::Floor($Value)|Measure-Object -Character).Characters -gt 3)
        if ($bool -or $KB) {
            $Value = $Value/$Unit; $Unit_Type = $Item
            if ($KB) { break }
        } else { break }
    }; $Value = [Math]::Round($Value, $Digit)

    # 對齊自動補上空白
    if ($Align) {
        $Space = ""
        $ValueWidth = $Value.ToString().Length
        $SpaceCount = $Width - $ValueWidth
        if ($SpaceCount -gt 0) { (1..$SpaceCount)|ForEach-Object{ $Space += " " } }
    }
    return ($Space + "$Value $Unit_Type")
} # FormatCapacity 18915618941



# RE系統相關設定
function EditRecovery {
    [CmdletBinding(DefaultParameterSetName = "Enable")]
    param (
        [Parameter(Position = 0, ParameterSetName = "Info")]
        [switch] $Info,
        [Parameter(Position = 0, ParameterSetName = "Remove")]
        [switch] $Remove,
        [Parameter(Position = 0, ParameterSetName = "Disable")]
        [Parameter(Position = 1, ParameterSetName = "Remove")]
        [switch] $Disable,
        [Parameter(Position = 0, ParameterSetName = "Enable")]
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
        # 刪除RE分區
        if ($Remove) {
            # 獲取RE分區位置
            $Part    = Get-RecoveryPartition -CurrentlyUsed
            $DiskNum = ($Part|Get-Disk).Number
            $PartNum = $Part.PartitionNumber
            $Capacity= FormatCapacity ($Part.Size)
            # 驗證
            if (!$Part) {
                Write-Error "錯誤:: 找不到RE修復分區, 可能是RE分區尚未啟用" -EA:Stop
            } else {
                if ($Part.DriveLetter -eq "C") {
                    Write-Warning "RE分區已經合併到C曹不需要再次執行"; return
                }
            }
            # 刪除RE分區(警告)
            ($Part|Get-Disk|Get-Partition) |Format-Table PartitionNumber,@{Name='DriveLetter'; Expression={if($_.DriveLetter){$_.DriveLetter}else{" "}}; Align='right'},@{Name='Size    '; Expression={$(FormatCapacity $_.Size -Align)}; Align='right'},Type -AutoSize
            Write-Host "即將刪除 [" -NoNewline
            Write-Host "磁碟:$($DiskNum), 分區:$($PartNum), 容量:$Capacity" -ForegroundColor:Yellow -NoNewline
            Write-Host "] 的RE分區, " -NoNewline
            Write-Host "刪除後無法復原" -ForegroundColor:Red -NoNewline
            Write-Host "請確保分區位置是正確的"
            if (!$Force) {
                $response = Read-Host "  沒有異議請輸入Y (Y/N) ";
                if ($response -ne "Y" -or $response -ne "Y") { Write-Host "使用者中斷" -ForegroundColor:Red; return; }
            }
            # 關閉RE系統
            reagentc /disable
            # 移除RE分區
            $Part|Remove-Partition
            if (!(Get-Partition -DiskNumber $DiskNum -PartitionNumber $PartNum -EA:0)) {
                # 確認
                Write-Host "已成功移除RE分區, 正在嘗試合併空閒空間..."
                # 合併釋放的空間到前一個分區
                $PartPre = Get-Partition -DiskNumber $DiskNum -PartitionNumber ($PartNum-1)
                $ReSize  = (($PartPre|Get-PartitionSupportedSize).SizeMax) - 1048576
                $PartPre | Resize-Partition -Size:$ReSize
                # 確認
                if ((Get-Partition -DiskNumber $DiskNum -PartitionNumber ($PartNum-1)).Size -eq $ReSize) {
                    Write-Host "空閒空間合併完成"
                } else { Write-Warning "空間合併失敗, 請手動合併剩餘空間" }
            }
            # 重新開啟RE系統
            if (!$Disable) {
                reagentc /enable
            } reagentc /info
            return
        }
        # 重啟RE分區
        if ($Enable) {
            reagentc /enable
            return
        # 關閉RE分區
        } elseif ($Disable) {
            reagentc /disable
            return
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
            return
        }
    }
}
# EditRecovery -SetReImg
# EditRecovery -Enable
# EditRecovery -Disable
# EditRecovery -Remove -Enable

# 拆分輸出的信息流
function Split-OutputStreams {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Array]$InputObjects
    )
    
    Begin {
        $allInputObjects = @()
    }
    
    Process {
        $allInputObjects += $InputObjects
    }
    
    End {
        $errorMessages = $allInputObjects | 
            Where-Object { $_ -is [System.Management.Automation.ErrorRecord] -and $_.Exception.Message.Trim() } | 
            ForEach-Object { $_.Exception.Message }

        $outputMessages = $allInputObjects |
            Where-Object { !($_ -is [System.Management.Automation.ErrorRecord]) -and $_.ToString().Trim() }

        return @{
            OutputMessages = $outputMessages
            ErrorMessages = $errorMessages
        }
    }
} # Split-OutputStreams $msg

# 格式化容量單位
function FormatCapacity {
    param (
        # 容量大小
        [Parameter(Position = 0, ParameterSetName = "")]
        [double] $Value = 0,
        # 小數點位數
        [Parameter(Position = 1, ParameterSetName = "")]
        [double] $Digit = 1,
        # 取到特定單位
        [Parameter(ParameterSetName = "")]
        [switch] $KB,
        [switch] $MB,
        # 格式化固定位寬
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
        if ((([Math]::Floor($Value)|Measure-Object -Character).Characters -gt 3)) {
            $Value = $Value/$Unit; $Unit_Type = $Item
            if ($KB -and ($Item -eq 'KB')) { break }
            if ($MB -and ($Item -eq 'MB')) { break }
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
} # FormatCapacity 18915618941 -MB

# 獲取延伸分區中的邏輯分區
function Get-ExtendedPartition {
    param (
        [Parameter(Position = 0, ParameterSetName = "")]
        [Uint16] $DiskNumber = 0
    )
    $Part = Get-Partition -DiskNumber $DiskNumber
    $Extend = $Part|Where-Object{$_.Type -match 'Extended'}
    if ($Extend) {
        $Begin  = $Extend.Offset
        $End    = $Extend.Offset + $Extend.Size
        $Result = $Part|Where-Object{($_.Offset -ge $Begin) -and ($_.Offset -lt $end) -and ($_.PartitionNumber -ne 0)}
        return $Result
    } else { return $Null }
} # Get-ExtendedPartition

# 判斷是否為邏輯分區 (延伸分區不算)
function IsExtendedPartition {
    param (
        [Object] $Partition
    )
    $Extend = Get-ExtendedPartition
    $Part = $Extend|Where-Object{($_.PartitionNumber -eq $Partition.PartitionNumber)}
    if ($Part) { return $true } else { return $false }
} # IsExtendedPartition (Get-Partition -DiskNumber 0 -PartitionNumber 0)

# 壓縮指定分區
function CompressPartition {
    [CmdletBinding(DefaultParameterSetName = "InputObject")]
    param (
        [Parameter(Position = 0, ParameterSetName = "DriveLetter", Mandatory)]
        [String] $DriveLetter,
        [Parameter(ParameterSetName = "InputObject", ValueFromPipeline ,Mandatory)]
        [Object] $InputObject,
        [Parameter(Position = 1, ParameterSetName = "DriveLetter" ,Mandatory)]
        [Parameter(Position = 0, ParameterSetName = "InputObject" ,Mandatory)]
        [Uint64] $Size,
        [Parameter(ParameterSetName = "")]
        [Switch] $Force, # 強制把未分配空間合併到目標分區
        [Switch] $OutNull
    )
    # 獲取目標分區
    if (!$InputObject) {
        $Dri = Get-Partition -DriveLetter:$DriveLetter -EA 0
    } else { $Dri = $InputObject|Get-Partition }
    if (!$Dri) { Write-Error "找不到磁碟槽位 `"$DriveLetter`:\`", 輸入可能有誤"; return }


    # 檢查是否為最後一個分區 (因為中間分區Get-PartitionSupportedSize不會計算未分配空間)
    $PartList = ($Dri|Get-Disk|Get-Partition)
    if (($PartList[-1]).UniqueId -eq $Dri.UniqueId){
        $IsFinalPartition = $true
    } else { 
        $IsFinalPartition = $false
        $PartIdx = 0; foreach ($Item in $PartList) { if ($Item.UniqueId -eq $Dri.UniqueId) { break }; $PartIdx++ }
        $NextPart = $PartList[$PartIdx+1]
    }

    # 查詢與計算空間
    $MinGapSize = 1048576
    $SupSize = $Dri|Get-PartitionSupportedSize
    $CurSize = $Dri.size
    if ($IsFinalPartition) {
        $MaxSize = $SupSize.SizeMax - $MinGapSize
    } else { $MaxSize = $NextPart.Offset - $Dri.Offset - $MinGapSize }
    $Unallocated = $MaxSize - $CurSize
    $CmpSize = $Null

    # 未分配空間扣除Size後小於特定大小則重新分配
    if (($Size -gt 0) -and ($Size -lt 1MB)) { $Size = 1MB }
    if ((($Unallocated-$Size) -le 4GB) -or $Force) {
        $ReSize = $MaxSize - $Size
        $CmpSize= $Size-$Unallocated
    }

    # 壓縮分區
    if ($CmpSize -and ($CmpSize -ne 0)) {
        # if (!$OutNull) { Write-Host "壓縮磁碟空間: $(FormatCapacity ($CmpSize) -Digit 3 -MB) ($(FormatCapacity $CurSize -Digit 3 -MB) -> $(FormatCapacity $ReSize -Digit 3 -MB))" }
        if (!$OutNull) { Write-Host "壓縮磁碟空間: $(FormatCapacity ($CmpSize) -Digit 3) ($(FormatCapacity $CurSize -Digit 3) -> $(FormatCapacity $ReSize -Digit 3))" }
        $Dri|Resize-Partition -Size:$ReSize -ErrorAction Stop|Out-Null
        Start-Sleep -Seconds 1
        return $Dri|Get-Partition
    } else {
        if (!$OutNull) { Write-Host "未使用空間充足無須壓縮" }
        return $False
    } return $Null
} # CompressPartition C 0MB -Force
# (Get-Partition -DiskNumber 0 -PartitionNumber 2)|CompressPartition 0

# 新增主分區(對應在MBR中建立第四個主分區)
function New-PrimaryPartition {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $DiskNumber,
        [Parameter(Mandatory = $true)]
        [string] $SizeMB
        # [switch] $UseMaximumSize
    )
    # 創建前的分區狀況
    $partitionsBefore = Get-Disk -Number $DiskNumber | Get-Partition

    # 創建分區
    $msg = "select disk $DiskNumber; create partition primary size=$SizeMB" -split ";" |diskpart.exe
    $msg = $msg -join " `r`n"

    # 創建後的分區狀況
    $partitionsAfter = Get-Disk -Number $DiskNumber | Get-Partition
    
    # 確認創建的分區
    $part = @($partitionsAfter | Where-Object { $_.PartitionNumber -notin $partitionsBefore.PartitionNumber })
    if ($part.Count -ne 1) {
        Write-Host $msg -ForegroundColor Yellow
        if (!$part) {
            Write-Error "分區創建失敗" -EA Stop
        } else {
            Write-Error "未知錯誤, 創建後不應該多出2個以上的分區" -EA Stop
        }
        return $null
    }
    
    return $part
} # New-PrimaryPartition -DiskNumber 0 -SizeMB 1024





# 獲取RE系統當前狀態
function Get-RecoveryStatus {
    $out = (reagentc /info 2>&1) |Split-OutputStreams
    if ($LASTEXITCODE) {
        $outMsg = $out.OutputMessages
        $errMsg = if($out.ErrorMessages){' ('+$out.ErrorMessages+')'}
        if ($outMsg) { Write-Host $outMsg }
        Write-Error "RE系統狀態獲取失敗$errMsg" -EA Stop
        return $null
    }
    $RecoveryPath = $out.OutputMessages -match("\\\\\?\\GLOBALROOT\\device")
    if ($RecoveryPath) { return $true } else { return $false }
} # Get-RecoveryStatus

# 設置RE系統狀態
function Set-RecoveryStatus {
    param (
        [Parameter(Position = 0, ParameterSetName = "Status", Mandatory)]
        [ValidateSet('Enable', 'Disable', 'ReEnable', 'ReMapping')]
        [String]$Status,
        [Parameter(ParameterSetName = "")]
        [Switch]$ShowInfo
    )
    
    # 啟用RE系統
    function EnableRecovery {
        if (-not (Get-RecoveryStatus)) {
            $out = (reagentc /Enable 2>&1) |Split-OutputStreams
            if ($LASTEXITCODE) {
                $outMsg = $out.OutputMessages
                $errMsg = if($out.ErrorMessages){' ('+$out.ErrorMessages+')'}
                if ($outMsg) { Write-Host $outMsg }
                Write-Error "RE系統啟用失敗$errMsg" -EA Stop
            }
        }
        
    }
    # 禁用RE系統
    function DisableRecovery {
        if (Get-RecoveryStatus) {
            $out = (reagentc /Disable 2>&1) |Split-OutputStreams
            if ($LASTEXITCODE) {
                $outMsg = $out.OutputMessages
                $errMsg = if($out.ErrorMessages){' ('+$out.ErrorMessages+')'}
                if ($outMsg) { Write-Host $outMsg }
                Write-Error "RE系統禁用失敗$errMsg" -EA Stop
            }
        }
    }
    # 重新映射RE系統
    function ReMappingRecovery {
        EnableRecovery
        $reAgentXML = "C:\Windows\System32\Recovery\ReAgent.xml"
        Rename-Item $reAgentXML "$reAgentXML.tmp" -ErrorAction SilentlyContinue
        DisableRecovery
        EnableRecovery
    }
    
    # 設置RE系統狀態
    switch ($Status) { 
        'Enable' { EnableRecovery }
        'Disable' { DisableRecovery }
        'ReEnable' { DisableRecovery; EnableRecovery }
        'ReMapping' { ReMappingRecovery }
    }
    
    # 顯示設置後的狀態
    if ($ShowInfo) {
        Write-Host (reagentc /Info |Out-String)
    }
} # Set-RecoveryStatus -Status Enable -ShowInfo

# 判定是否為RE分區
function IsRecoveryPartition {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory, ValueFromPipeline)]
        [Object] $Partition,
        [String] $LabelPattern = ""
    )
    # 獲取分區標籤
    $label = ($Partition|Get-Volume).FileSystemLabel
    # ((GPT修復分區 -or MBR修復分區) -and 空磁碟標籤)
    return ((($Partition.Type -eq 'Recovery') -or ($Partition.MbrType -eq 39)) -and ($label -like $LabelPattern))
} # IsRecoveryPartition (Get-Partition -DiskNumber 0 -PartitionNumber 2)

# 獲取RE分區
function Get-RecoveryPartition {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param (
        [Parameter(ParameterSetName = "Default")]
        [String] $SystemLetter,
        [Parameter(ParameterSetName = "CurrentlyUsed")]
        [switch] $CurrentlyUsed,
        [Parameter(ParameterSetName = "CurrentlyUsed")]
        [switch] $ForceEnable, # 查詢完會保持開啟狀態(維持返回物件與真實狀況的一致性)
        [String] $LabelPattern = ""
    )
    # 指定磁碟機中所有RE分區
    if ($SystemLetter) {
        $Dri = Get-Partition -DriveLetter $SystemLetter -EA 0
        if ($Dri) {
            return $Dri |Get-Disk|Get-Partition |Where-Object{ IsRecoveryPartition $_ -LabelPattern $LabelPattern }
        } else { return $Null }
    } else { $CurrentlyUsed = $true }
    # 當前系統使用中的RE分區
    if ($CurrentlyUsed) {
        # 確認啟用狀態
        $RecoveryPath = [string]((reagentc /info) -match("\\\\\?\\GLOBALROOT\\device"))
        if ($RecoveryPath -eq '') {
            if ($ForceEnable) {
                # 重新確認啟用狀態
                Write-Host "RE系統尚未啟用無法獲取分區位置, 嘗試啟用中... " -NoNewline
                (reagentc /enable) |Out-Null; (reagentc /enable) |Out-Null
                $RecoveryPath = [string]((reagentc /info) -match("\\\\\?\\GLOBALROOT\\device"))
                if ($RecoveryPath -eq '') { Write-Error "無法啟用"; return } else { Write-Host "啟用成功" }
            }
        }
        # 解析路徑並獲取分區物件
        if ($RecoveryPath) {
            $DiskNum = (([regex]('\\harddisk([0-9]+)\\')).Matches($RecoveryPath)).Groups[1].Value
            $PartNum = (([regex]('\\partition([0-9]+)\\')).Matches($RecoveryPath)).Groups[1].Value
            return Get-Partition -DiskNumber $DiskNum -PartitionNumber $PartNum
        } return $Null
    }
} # Get-RecoveryPartition -ForceEnable

# 建立RE分區
function New-RecoveryPartition {
    [CmdletBinding(DefaultParameterSetName = "")]
    param (
        [Parameter(ParameterSetName = "")]
        [Uint64] $Size = 1024MB,
        [Parameter(ParameterSetName = "")]
        [String] $CompressDriveLetter = 'C',
        [Parameter(ParameterSetName = "")]
        [Switch] $ReMappingRecovery,
        [Parameter(ParameterSetName = "")] [Alias("RestartRecovery")]
        [Switch] $ReEnableRecovery
    )
    # 獲取目標分區
    $MinGapSize = 1048576
    $Dri = Get-Partition -DriveLetter:$CompressDriveLetter -EA 0
    $DiskNumber = ($Dri|Get-Disk).DiskNumber
    if (!$Dri) { Write-Error "找不到磁碟槽位 `"$CompressDriveLetter`:\`", 輸入可能有誤" }
    CompressPartition -DriveLetter $CompressDriveLetter -Size $Size |Out-Null
    Start-Sleep -Seconds 2
    $Size = $Size-$MinGapSize
    # 判斷磁碟型態
    $DiskType = ($Dri|Get-Disk).PartitionStyle
    if ($DiskType -eq "GPT") {
        $RePart = ($Dri|New-Partition -Size $Size|Format-Volume -FileSystem:NTFS)|Get-Partition
        if ($RePart) {
            $DiskNumber      = ($RePart|Get-Disk).DiskNumber
            $PartitionNumber = $RePart.PartitionNumber
            $TypeID          = 'de94bba4-06d1-4d40-a16a-bfd50179d6ac'
            $Attributes      = '0x8000000000000001'
            "select disk $DiskNumber; select partition $PartitionNumber; set id=$TypeID override; gpt attributes=$Attributes" -split ";" |diskpart.exe |Out-Null
        } else { return $Null}
    } elseif ($DiskType -eq "MBR") {
        $Size = $Size/1MB
        $NewPart = New-PrimaryPartition -DiskNumber $DiskNumber -SizeMB $Size
        $RePart = $NewPart |Format-Volume |Get-Partition
        if ($RePart) {
            $RePart|Set-Partition -MbrType 39
        } else { return $Null}
    }
    # 重新啟用RE系統
    if ($ReMappingRecovery) {
        Set-RecoveryStatus ReMapping -ShowInfo
    } elseif ($ReEnableRecovery) {
        Set-RecoveryStatus ReEnable -ShowInfo
    }
    return ($RePart|Get-Partition)
} # New-RecoveryPartition -Size 1024MB -ReMappingRecovery

# 刪除RE分區
function Remove-RecoveryPartition {
    [CmdletBinding(DefaultParameterSetName = "Partition")]
    param (
        [Parameter(ParameterSetName = "Partition", ValueFromPipeline, Mandatory)]
        [Object] $Partition,
        [Parameter(ParameterSetName = "CurrentlyUsed")]
        [Switch] $CurrentlyUsed,
        [Switch] $ForceEnable, # 刪除後不會保持啟動狀態(邏輯上是因為刪除了所以變成關閉狀態了)
        [Parameter(ParameterSetName = "")]
        [Switch] $Merage
    )
    # 獲取RE系統的初始狀態
    $InitStatus = Get-RecoveryStatus
    # 獲取RE分區
    if ($CurrentlyUsed) { # 當前系統使用中RE分區
        $Partition = Get-RecoveryPartition -CurrentlyUsed:$CurrentlyUsed -ForceEnable:$ForceEnable
        if (!$Partition) { Write-Warning "RE系統非啟用狀態 (請手動啟用後再執行,或追加 -ForceEnable 指令)"; return }
        if ($Partition.DriveLetter -eq "C") {
            reagentc /Info |Format-Table; Write-Warning "當前RE系統所使用的分區是系統分區, 無須刪除"; return
        } else { Set-RecoveryStatus -Status Disable }
    } else { # 使用者輸入的分區
        $Partition = $Partition|Get-Partition -EA 0
        if (!$Partition) { Write-Warning "輸入的分區物件無效"; return }
        # 確認分區有效性是否為修復分區
        if (($Partition.Type -eq 'Recovery') -or ($Partition.MbrType -eq 39)) {
        } else { $Partition|Format-Table; Write-Warning "該分區不是修復分區"; return }
        # 確認分區是否為當前RE系統使用中的分區
        if ((Get-RecoveryStatus)) { # 只在有啟用才確認, 關閉狀態不影響就不確認了
            if ((Get-RecoveryPartition -CurrentlyUsed).UniqueId -eq $Partition.UniqueId) { Set-RecoveryStatus -Status Disable }
        }
    }

    # 獲取分區索引
    $PartList = ($Partition|Get-Disk|Get-Partition)
    $PartIdx  = 0; foreach ($Item in $PartList) { if ($Item.UniqueId -eq $Partition.UniqueId) { break }; $PartIdx++ }
    $PrePartIdx = $PartIdx -1
    
    # 檢測該RE分區是否為單一邏輯分區
    if ((IsExtendedPartition $Partition) -and (@(Get-ExtendedPartition).Count -eq 1)) { $DeleteExtendPart = $true }

    # 刪除分區
    Get-Partition |Format-Table @{Name='Number'; Expression={$_.PartitionNumber}; Align='left'}, @{Name='Letter'; Expression={if($_.DriveLetter){$_.DriveLetter}else{" "}}; Align='left'}, @{Name='Size     '; Expression={$(FormatCapacity $_.Size -Align)}; Align='right'}, Type -AutoSize
    Write-Host "即將刪除 磁碟:$(($Partition|Get-Disk).Number) [" -NoNewline
    Write-Host "分區:$($Partition.PartitionNumber), 容量:$(FormatCapacity $Partition.Size)" -ForegroundColor Yellow -NoNewline
    Write-Host "] 的RE分區, " -NoNewline
    Write-Host "刪除後無法復原" -ForegroundColor:Red -NoNewline
    Write-Host "請確保分區位置是正確的"
    # 移除分區
    if ($DeleteExtendPart) {
        $Partition|Remove-Partition -ErrorAction Stop
        Write-Host "已成功移除RE分區..." -ForegroundColor DarkGreen
        Write-Host "但檢測到該RE分區是邏輯分區, 且該延伸分區內沒有其他邏輯分區"
        Write-Host "是否刪除延伸磁碟分區? (若不刪除會無法合併到主分區)" -ForegroundColor:Red
        $PartList[$PrePartIdx]|Remove-Partition -ErrorAction Stop
        $PrePartIdx = $PrePartIdx -1
    } else {
        $Partition|Remove-Partition -ErrorAction Stop
        $RePartitionRemoved = !($Partition | Get-Partition -ErrorAction SilentlyContinue)
        if ($RePartitionRemoved) {
            Write-Host "已成功移除RE分區" -ForegroundColor DarkGreen
        } else {
            Write-Host "RE分區沒有被移除, 使用者拒絕了移除請求" -ForegroundColor Red
        }
    }

    # 恢復RE系統初始狀態
    if ($InitStatus) { Set-RecoveryStatus -Status Enable }
    # 合併未分配容量到前方分區
    if ($Merage -and $RePartitionRemoved) {
        Write-Host "正在嘗試向前合併刪除後的未分配空間..."
        if (($PartIdx -gt 0)) {
            $PrePart = $PartList[$PrePartIdx]
            if (!(IsRecoveryPartition $PrePart)) {
                try {
                    $PrePart|CompressPartition 0 -OutNull -Force -ErrorAction Stop|Format-Table
                } catch { Write-Error "合併失敗, 請手動合併未分配空間"; return }
                Write-Host "合併完成, 已合併到上記分區"
            } else { Write-Warning "無法合併, 前方分區是RE分區" }
        } else { Write-Warning "無法合併, 前方沒有分區可以合併" }
    }
    return
} # Remove-RecoveryPartition -CurrentlyUsed -Merage -ForceEnable
# (Get-Partition -DiskNumber 0 -PartitionNumber 4)| Remove-RecoveryPartition -Merage
# (Get-RecoveryPartition -S C) |ForEach-Object { $_|Remove-RecoveryPartition -Merage }

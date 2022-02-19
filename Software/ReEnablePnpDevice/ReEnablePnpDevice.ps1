function ReEnablePnpDevice {
    [CmdletBinding(DefaultParameterSetName = "FormatType")]
    param (
        [Parameter(Position = 0, ParameterSetName = "FriendlyName")]
        [string] $FriendlyName,
        [Parameter(Position = 0, ParameterSetName = "IntelDisplay")]
        [switch] $IntelDisplay
    )
    if ($IntelDisplay) { $FriendlyName = "Intel(R) UHD Graphics" }
    $PnpDevice = (Get-PnpDevice -FriendlyName:$FriendlyName)
    $PnpDevice|Disable-PnpDevice -confirm:$false
    $PnpDevice|Enable-PnpDevice -confirm:$false
}
# ReEnablePnpDevice "Intel(R) UHD Graphics"
# ReEnablePnpDevice -IntelDisplay

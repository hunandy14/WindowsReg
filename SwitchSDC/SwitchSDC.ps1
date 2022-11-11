$PnpDevice = (Get-PnpDevice -Class:Display) -notmatch "NVIDIA|AMD"
$PnpDevice|Disable-PnpDevice -Confirm:$false; $PnpDevice|Enable-PnpDevice -Confirm:$false

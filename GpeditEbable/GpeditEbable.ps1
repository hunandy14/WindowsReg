function GpeditEbable() {
    $GpeditName = "(Microsoft-Windows-GroupPolicy-ClientExtensions-Package~3)(.*?)(\.mum)|(Microsoft-Windows-GroupPolicy-ClientTools-Package~3)(.*?)(\.mum)"
    $GepeditPackag = (Get-ChildItem $env:SystemRoot\servicing\Packages) -match ($GpeditName)
    ($GepeditPackag.FullName) | ForEach-Object { dism /online /norestart /add-package:$_ }
    gpedit.msc
} # GpeditEbable
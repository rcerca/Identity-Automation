cls
$DCs= "Server01","Server02","Server03"

ForEach ($DC in $DCs)
{
 Write-host `n
 Write-host "$DC" -BackgroundColor DarkYellow
 Write-host "Before update" -BackgroundColor DarkMagenta
 ((Get-DnsServerForwarder -ComputerName $dc).IPAddress).IPAddressToString
 
 Write-host "Updating ..."
 $x = Get-Random -InputObject "8.8.8.8","9.9.9.9" -Count 2
 $1 = $x | select -First 1
 $2 = $x | select -Last 1
 Set-DnsServerForwarder -ComputerName $dc -IPAddress $1,$2,"9.9.9.11" -EnableReordering $False -PassThru | Out-Null #>
 
 Write-host "After update" -BackgroundColor DarkGreen
 ((Get-DnsServerForwarder -ComputerName $dc).IPAddress).IPAddressToString
}

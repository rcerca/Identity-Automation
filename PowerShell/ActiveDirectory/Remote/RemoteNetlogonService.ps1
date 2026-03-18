cls
$SrvNames = "Server01","Server02"

foreach ($Server in $SrvNames)
{
  New-PSSession -ComputerName $Server
  Enter-PSSession -ComputerName $Server
  Hostname
  Get-Service -Name Netlogon -ComputerName $Server | Stop-Service -PassThru | Set-Service -StartupType disabled
  Exit-PSSession
  Remove-PSSession -Name $Server
} 

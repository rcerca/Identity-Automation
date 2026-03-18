Clear-host
$LDAPservers = "Server01.FQDN,"Server02.FQDN", "Server03.FQDN"

Write-host "`nTest Ports" -BackgroundColor DarkGreen
Foreach ($Server in $LDAPservers)
   { Test-NetConnection -ComputerName $server -Port 636 | select ComputerName,RemoteAddress,RemotePort,TcpTestSucceeded
      Test-NetConnection -ComputerName $server -Port 389 | select ComputerName,RemoteAddress,RemotePort,TcpTestSucceeded } 
   
Write-host "`nDCDIAG (No results mean server passed in all dcdiag tests)" -BackgroundColor DarkGreen 
Foreach ($Server in $LDAPservers)
   { Write-host "Running DCDIAG - $server" -BackgroundColor DarkMagenta
     dcdiag /s:$server /test:Connectivity /test:MachineAccount /test:Topology /test:Services /q } 
 
Write-host "`nCPU %" -BackgroundColor DarkGreen
Foreach ($Server in $LDAPservers)
   { $CPU = Invoke-Command -ComputerName $server -ScriptBlock { (Get-WmiObject -Class Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average }
     Write-host "$server - CPU consuming: $cpu%" }

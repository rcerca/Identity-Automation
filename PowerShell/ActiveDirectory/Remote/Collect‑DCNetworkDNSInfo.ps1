Clear
$result =@()
$Servers = (Get-ADDomain).ReplicaDirectoryServers | sort
$result = @()

foreach ($s in $servers) {

    try {
        $session = New-PSSession -ComputerName $s -ErrorAction Stop
    }
    catch {
        Write-Host "Could not connect to server: $s" -ForegroundColor Red
        continue
    }

    try {
        $net = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled=TRUE" -ComputerName $s |
               Select-Object DNSHostName, DNSServerSearchOrder

        $dns = Get-DnsServerForwarder -ComputerName $s |
               Select-Object IPAddress

        $obj = [pscustomobject]@{
            Name                 = $net.DNSHostName
            DNSServerSearchOrder = $net.DNSServerSearchOrder
            DNSForwarder         = $dns.IPAddress
        }

        $result += $obj
    }
    catch {
        Write-Host "Error retrieving DNS info from $s" -ForegroundColor Yellow
    }

    Remove-PSSession $session
}

$result | Select-Object Name,@{Name='DNSServerSearchOrder'; Expression = { $_.DNSServerSearchOrder -join ';' }},@{Name='DNSForwarder'; Expression = { $_.DNSForwarder }} | Export-Csv C:\DC-netDNS.csv -NoTypeInformation

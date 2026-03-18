Clear-Host

$computers = (get-addomain).ReplicaDirectoryServers | sort 

Write-Host "SERVER LAST BOOT REPORT" -BackgroundColor DarkBlue -ForegroundColor White
Write-Host ""

foreach ($computer in $computers) {

    try {
        $info = Get-CimInstance Win32_OperatingSystem -ComputerName $computer

        Write-Host ("{0,-25}  {1}" -f $info.PSComputerName, $info.LastBootUpTime)

    } catch {
        Write-Host ("{0,-25}  UNREACHABLE (WinRM error)" -f $computer) -BackgroundColor DarkRed
    }
}

Write-Host ""
Write-Host "Report complete." -ForegroundColor Green

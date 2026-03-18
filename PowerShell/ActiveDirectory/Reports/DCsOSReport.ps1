Clear

# Get all domains in the forest
$Domains = (Get-ADForest).Domains
$TotalG = 0

Write-Host "DOMAIN CONTROLLER OS SUMMARY" -BackgroundColor DarkBlue -ForegroundColor White
Write-Host ""

foreach ($Domain in $Domains) {

    # Counters
    $16 = $19 = $22 = $25 = 0

    # Get one DC to extract the DefaultPartition
    $DC = Get-ADDomainController -Filter * -Server $Domain |
          Select-Object @{n="HostName";e={$_.HostName}}, DefaultPartition -Last 1

    # Get all DC computer objects from the correct partition
    $computers = Get-ADComputer -SearchBase "OU=Domain Controllers,$($DC.DefaultPartition)" `
                                -Filter * -Properties OperatingSystem `
                                -Server $DC.HostName |
                 Select-Object Name, OperatingSystem

    foreach ($comp in $computers) {
        if ($comp.OperatingSystem -like "Windows Server 2016*") { $16++ }
        if ($comp.OperatingSystem -like "Windows Server 2019*") { $19++ }
        if ($comp.OperatingSystem -like "Windows Server 2022*") { $22++ }
        if ($comp.OperatingSystem -like "Windows Server 2025*") { $25++ }
    }

    # Output block for each domain
    Write-Host "============================================="
    Write-Host "DOMAIN: $Domain" -BackgroundColor DarkGreen -ForegroundColor White
    Write-Host "---------------------------------------------"
    Write-Host ("Windows Server 2016 : {0}" -f $16)
    Write-Host ("Windows Server 2019 : {0}" -f $19)
    Write-Host ("Windows Server 2022 : {0}" -f $22)
    Write-Host ("Windows Server 2025 : {0}" -f $25)

    $Total = $16 + $19 + $22 + $25
    Write-Host ("Total DCs in domain : {0}" -f $Total) -BackgroundColor DarkCyan

    $TotalG += $Total
    Write-Host ""
}

Write-Host "============================================="
Write-Host "TOTAL DCs IN FOREST: $TotalG" -BackgroundColor DarkRed -ForegroundColor White
Write-Host "============================================="

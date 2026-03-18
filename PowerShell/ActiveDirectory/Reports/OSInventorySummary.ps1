Clear-Host

# Collect all enabled computers with OS info
$LstServers = Get-ADComputer -Filter * -Properties OperatingSystem |
              Where-Object { $_.Enabled -eq $true } |
              Select-Object OperatingSystem

# Define OS categories and patterns
$Categories = @(
    @{ Label = "Mac";                Pattern = "Mac*" }
    @{ Label = "Cisco";              Pattern = "Cisco*" }
    @{ Label = "Hyper-V";            Pattern = "Hyper-V*" }
    @{ Label = "NetApp";             Pattern = "NetApp*" }
    @{ Label = "Windows 10";         Pattern = "Windows 10*" }
    @{ Label = "Windows 11";         Pattern = "Windows 11*" }
    @{ Label = "Windows 8.1";        Pattern = "Windows 8*" }
    @{ Label = "Windows 7";          Pattern = "Windows 7*" }
    @{ Label = "Windows Embedded";   Pattern = "Windows Embedded*" }
    @{ Label = "Server 2008";        Pattern = "*2008*" }
    @{ Label = "Server 2008 R2";     Pattern = "*2008 R2*" }
    @{ Label = "Server 2012";        Pattern = "*2012*" ; Exclude = "*R2*" }
    @{ Label = "Server 2012 R2";     Pattern = "*2012 R2*" }
    @{ Label = "Server 2016";        Pattern = "*2016*" }
    @{ Label = "Server 2019";        Pattern = "*2019*" }
    @{ Label = "Server 2022";        Pattern = "*2022*" }
    @{ Label = "Server 2025";        Pattern = "*2025*" }
    @{ Label = "Unknown";            Pattern = "*unknown*" }
    @{ Label = "Null";               Pattern = $null }
)

Write-Host "OPERATING SYSTEM INVENTORY SUMMARY" -BackgroundColor DarkBlue -ForegroundColor White
Write-Host ""

foreach ($cat in $Categories) {

    if ($cat.Pattern -eq $null) {
        $Count = ($LstServers | Where-Object { $_.OperatingSystem -eq $null }).Count
    }
    elseif ($cat.ContainsKey("Exclude")) {
        $Count = ($LstServers | Where-Object {
            $_.OperatingSystem -like $cat.Pattern -and
            $_.OperatingSystem -notlike $cat.Exclude
        }).Count
    }
    else {
        $Count = ($LstServers | Where-Object { $_.OperatingSystem -like $cat.Pattern }).Count
    }

    Write-Host ("{0,-20}: {1}" -f $cat.Label, $Count)
}

Write-Host ""
Write-Host "Inventory complete." -ForegroundColor Green

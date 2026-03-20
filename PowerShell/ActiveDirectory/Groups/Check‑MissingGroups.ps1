clear
$words = "AAAA","BBBB","CCCC","DDDD","EEEE"
$missingGroups = @()

foreach ($w in $words) 
   { $found = Get-ADGroup -Filter "Name -eq '$w-GROUPSUFFIX'" -ErrorAction SilentlyContinue

    if (-not $found) 
       { $missingGroups += $w }
   }

# Output only the groups that do not exist
Write-Host "`nGroups NOT found:" -ForegroundColor Yellow
$missingGroups | sort

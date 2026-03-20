############################################### OPTION 1
CLEAR

function Get-AllReports {
    param(
        [string]$Manager,
        [int]$Level = 0,
        [switch]$IsRoot
    )

    # Tree characters
    $branch = "├─ "
    $last   = "└─ "
    $pipe   = "│  "
    $space  = "   "

    # Print root manager only once
    if ($IsRoot) {
        Write-Output "Manager: $Manager"
    }

    # Get direct reports
    $DirectReports = Get-ADUser -Filter { manager -eq $Manager } -Properties DisplayName |
                     Select-Object DistinguishedName, DisplayName

    $count = $DirectReports.Count
    $i = 0

    foreach ($dr in $DirectReports) {
        $i++

        # Determine symbol without using ternary operator
        if ($i -eq $count) {
            $symbol = $last
        } else {
            $symbol = $branch
        }

        # Build indentation prefix
        $prefix = ""
        if ($Level -gt 0) {
            $prefix = ($pipe * $Level)
        }

        # Print the report
        Write-Output ("{0}{1}{2}" -f $prefix, $symbol, $dr.DisplayName)

        # Recurse
        Get-AllReports -Manager $dr.DistinguishedName -Level ($Level + 1)
    }
}

$ManagerName = "UserName"
Get-AllReports -Manager $ManagerName -Level 0 -IsRoot


############################################### OPTION 2
CLEAR

function Get-AllReports {
    param(
        [string]$Manager,
        [int]$Level = 0,
        [switch]$IsRoot
    )

    # indentation based on level
    $indent = " " * ($Level * 4)

    # print the root manager only once
    if ($IsRoot) {
        Write-Output "$indent Manager/Employee: $Manager"
    }

    # get direct reports
    $DirectReports = Get-ADUser -Filter { manager -eq $Manager } | Select-Object DistinguishedName

    foreach ($dr in $DirectReports) {

        # print the report
        Write-Output "$indent    Report (Level $Level): $($dr.DistinguishedName)"

        # recurse into next level (do NOT print manager again)
        Get-AllReports -Manager $dr.DistinguishedName -Level ($Level + 1)
    }
}

$ManagerName = "UserName"
Get-AllReports -Manager $ManagerName -Level 0 -IsRoot



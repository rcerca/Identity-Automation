Clear

# Get direct reports (DNs)
$DirectReports = (Get-ADUser <Accountname> -Properties directReports).directReports

# Build list of locations for each direct report
$UserProperties = foreach ($dr in $DirectReports) {

    $user = Get-ADUser -Identity $dr -Properties l, SamAccountName

    [PSCustomObject]@{
        Name     = $user.SamAccountName
        Location = $user.l
    }
}

$UserProperties

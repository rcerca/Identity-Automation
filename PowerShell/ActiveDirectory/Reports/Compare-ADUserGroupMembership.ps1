Clear-Host

# Ensure the ActiveDirectory module is loaded
if (-not (Get-Module ActiveDirectory)) {
    Import-Module ActiveDirectory
}

# User accounts to compare
$UserName1 = "Account1"
$UserName2 = "Account2"

# Retrieve AD user objects including their group memberships (MemberOf)
# The -Server parameter forces the query to a specific domain controller
$userAccount1 = Get-ADUser -Identity $UserName1 -Properties MemberOf 
$userAccount2 = Get-ADUser -Identity $UserName2 -Properties MemberOf 

# Compare the group membership lists of both users
# -IncludeEqual shows groups that both users share
$comparison = Compare-Object `
    -ReferenceObject $userAccount1.MemberOf `
    -DifferenceObject $userAccount2.MemberOf `
    -IncludeEqual

# Replace Compare-Object indicators with meaningful labels
foreach ($item in $comparison) {

    switch ($item.SideIndicator) {
        "<=" { $item.SideIndicator = "$UserName1 only" }
        "=>" { $item.SideIndicator = "$UserName2 only" }
        "==" { $item.SideIndicator = "Both users" }
    }
}

# Display the results in a clean, readable table
$comparison |
    Select-Object `
        @{l='User'; e={$_.SideIndicator}},
        @{l='Group DN'; e={$_.InputObject}} |
    Format-Table -AutoSize

Clear
function Get-GroupMembersRecursive {
    param(
        [Parameter(Mandatory = $true)]
        [string]$GroupName,

        [int]$Level = 0
    )

    # Indentation based on level
    $indent = " " * ($Level * 4)

    Write-Output "$indent Subgroup (Level $Level): $GroupName"

    # Get direct members
    $members = Get-ADGroupMember -Identity $GroupName -Recursive:$false

    # Separate users and groups
    $userMembers  = $members | Where-Object { $_.objectClass -eq "user" }
    $groupMembers = $members | Where-Object { $_.objectClass -eq "group" }

    # List users first
    foreach ($u in $userMembers) {
        $user = Get-ADUser -Identity $u.DistinguishedName -Properties DisplayName
        Write-Output "$indent    User (Level $Level): $($user.DisplayName)"
    }

    # Then list groups and recurse
    foreach ($g in $groupMembers) {
        Write-Output "`n$indent    Group (Level $Level): $($g.Name)"
        Get-GroupMembersRecursive -GroupName $g.DistinguishedName -Level ($Level + 1)
    }
}

# Main group name
$mainGroupName = "Group_Name"

# Start recursion
Get-GroupMembersRecursive -GroupName $mainGroupName -Level 0

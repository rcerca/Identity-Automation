Import-Module ActiveDirectory
Import-Module GroupPolicy

# Get all OUs in the domain
$OUs = Get-ADOrganizationalUnit -Filter * -SearchScope Subtree

$results = foreach ($ou in $OUs) {
    $links = Get-GPInheritance -Target $ou.DistinguishedName
    foreach ($link in $links) {
        [PSCustomObject]@{
            OU        = $ou.DistinguishedName
            GPO       = $link.DisplayName
            Enabled   = $link.Enabled
            Enforced  = $link.Enforced
        }
    }
}

# Show results in table
$results | Format-Table -AutoSize

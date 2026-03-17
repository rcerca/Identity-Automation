Import-Module ActiveDirectory
Import-Module GroupPolicy

# Get all OUs in the domain
$OUs = Get-ADOrganizationalUnit -Filter * -SearchScope Subtree

$results = foreach ($ou in $OUs) {
    $links = Get-GPInheritance -Target $ou.DistinguishedName
    foreach ($link in $links) {
        [PSCustomObject]@{
            OU        = $link.path
            InheritanceBlocked   = $link.GpoInheritanceBlocked
            GPOLinks = ($link.GpoLinks  | % { ($_.displayName) }) -join “,”
            InheritedGpoLinks  =  ( $link.InheritedGpoLinks | % { ($_.displayName) }) -join “,” 

        }
    }
}

# Show results in table
$results | Format-Table -AutoSize

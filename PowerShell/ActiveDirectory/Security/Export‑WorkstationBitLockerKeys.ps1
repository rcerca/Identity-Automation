$SearchBases = (Get-ADOrganizationalUnit -Filter * -SearchBase (Get-ADDomain).DistinguishedName -SearchScope Subtree | ?{$_.DistinguishedName -like "OU=Workstations*"}).DistinguishedName
foreach ($SearchBase in $SearchBases)
{
 $computers = Get-ADComputer  -Filter * -SearchBase $SearchBase 
 $OU = $SearchBase | %{$_.split(',')[1]}
 $SpiritCode = $OU -replace '.*='
 $ExportedFile = "$SpiritCode.csv"
 $Fullpath = Join-Path -Path C:\CS-Issue -ChildPath $ExportedFile
 
 foreach ($computer in $computers) {
     $Key = Get-ADObject -Filter 'objectClass -eq "msFVE-RecoveryInformation"' -SearchBase $computer.DistinguishedName -Properties whenCreated, msFVE-RecoveryPassword  |
     Sort whenCreated -Descending | Select-Object msFVE-RecoveryPassword |  Select-Object -First 1
     [pscustomobject]@{
                     "Computer Name" = $Computer.Name;
                     "Enabled" = $Computer.Enabled;
                     "Bitlocker Key" = $Key
                 } | Export-Csv -Path $Fullpath -NoClobber -NoTypeInformation -Append
 }
}

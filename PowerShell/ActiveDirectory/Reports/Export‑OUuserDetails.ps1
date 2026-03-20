$spt = Get-Content C:\tmp\Ricardo.txt
foreach ($s in $spt)
 { $ou = (Get-ADOrganizationalUnit -Filter {name -eq $s}).DistinguishedName
   $OUusers = ("OU=Users,"+$ou)
   $OUusers
   get-aduser -filter * -SearchBase "$OUusers" -pr l,DisplayName,EmailAddress,Title,employeeStatus | select SamAccountName, DisplayName,l,EmailAddress,Title,employeeStatus | Export-Csv -Path c:\tmp\Art51724-3.csv -NoTypeInformation -Append
 }

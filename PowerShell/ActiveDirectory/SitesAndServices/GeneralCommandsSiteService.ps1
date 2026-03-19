#list all sitelinks
Get-ADReplicationSiteLink -Filter * | ? {($_.SitesIncluded).count -le "1" } | select Name,@{n=’SitesIncluded’; e= { ( $_.SitesIncluded) -join “,” }} | export-csv c:\temp\CHG0131975_BKP.csv -NoTypeInformation

#DELETE THE SITELINKS
$sites = ((Get-ADReplicationSiteLink -Filter * | ? {($_.SitesIncluded).count -gt "1" } | select Name).name).count
foreach ($s in $sites)
  { Remove-ADReplicationSiteLink -Identity $s }

# This script reads a list of site link names from SiteLink.csv, retrieves each corresponding
# Active Directory replication site link, and renames it to the new name specified in the CSV.
# The CSV must contain at least two columns: "SiteL" (current site link name) and "New" (new name).
$sites = import-csv C:\Scripts\Ricardo\SiteLink.csv
foreach ($s in $sites)
{ 
  $siteLinkDN = (Get-ADReplicationSiteLink $s.SiteL).DistinguishedName
  Rename-ADObject -Identity $siteLinkDN -NewName $S.New
}

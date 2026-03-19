#export list of sitelinks and Replication Frequency In Minutes
Get-ADReplicationSiteLink -Filter * | ?{$_.ReplicationFrequencyInMinutes -ne "15"} | select Name,ReplicationFrequencyInMinutes | export-csv C:\Temp\ReplicationInterval.csv -NoTypeInformation

#change Replication Frequency In Minutes
$Sites = (Get-ADReplicationSiteLink -Filter * | ?{$_.ReplicationFrequencyInMinutes -ne "15"}).name 
foreach ($s in $sites)
{ 
  Get-ADReplicationSiteLink $s | select Name,ReplicationFrequencyInMinutes
  Set-ADReplicationSiteLink -Identity $s -ReplicationFrequencyInMinutes 15
 }

#rollback (if necessary)
$Sites = Import-Csv C:\GAD\Changes\ReplicationInterval.csv
foreach ($s in $sites)
{ Set-ADReplicationSiteLink -Identity $s.name -ReplicationFrequencyInMinutes $s.ReplicationFrequencyInMinutes }

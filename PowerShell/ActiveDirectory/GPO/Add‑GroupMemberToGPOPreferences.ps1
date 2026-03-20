cls
$GPOs = "GPO Name"
$dc =(Get-ADDomain).PDCEmulator
$G_Workst = "GroupName" #Group that will be added 

foreach ($GPO in $GPOs)
{
  Write-host $GPO -BackgroundColor DarkGreen
  Set-Location C:
  $NewGrp = get-adgroup $G_Workst
  $NewSAM = $NewGrp.SamAccountName
  $newSID = $NewGrp.SID
  $laGUID=(Get-GPO  -Name $GPO).Id
  $laGPO="\\$($dc)\C$\Windows\SYSVOL\domain\Policies\{$($laGUID)}\Machine\Preferences\Groups\Groups.xml"

  [xml]$xml= (Get-Content -path $laGPO)  
  $member=$xml.CreateElement('Member')
  $member.SetAttribute('name',"HHC\$($NewGrp.SamAccountName)")
  $member.SetAttribute('action',"ADD")
  $member.SetAttribute('sid',"$($NewGrp.Sid)")
  $xml.Groups.Group.Properties.Members.AppendChild($member)
  $xml.Save($laGPO) 
}

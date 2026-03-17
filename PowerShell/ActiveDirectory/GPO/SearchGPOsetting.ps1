# Search GPO setting
cls
$String = "Advanced Audit Policy Configuration" #Script will search GPOs that have "Advanced Audit Policy Configuration" set.
$Domain = (get-addomain).DNSRoot
$NearestDC = (Get-ADDomainController -Discover -NextClosestSite).Name

$GPOs = get-gpo -all -Domain $Domain -Server $NearestDC

Foreach ($GPO in $GPOs)  {
  $CurrentGPOReport = Get-GPOReport -Guid $GPO.ID -ReportType Xml -Domain $Domain -Server $NearestDC
  If ($CurrentGPOReport -like "*$String*")  {
	Write-Host "-  GPO Name: $($GPO.DisplayName)" -Foregroundcolor Green
  }
}

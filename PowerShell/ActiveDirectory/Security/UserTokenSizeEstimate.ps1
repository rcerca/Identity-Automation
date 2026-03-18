Clear

$ID="2500502"

$user=Get-ADUser -LDAPFilter "(&(name=$ID))" -Properties PrimaryGroup,SidHistory

$gc=Get-ADDomainController -Discover -Service GlobalCatalog

$membership=Get-ADGroup -LDAPFilter "(&(member:1.2.840.113556.1.4.1941:=$($user.DistinguishedName)))" -Server "$($gc.HostName):3268"

$groups=@($membership; Get-ADGroup -Identity $user.PrimaryGroup)

$large=@($groups | ?{($_.GroupScope -eq 'DomainLocal') -or ($_.GroupScope -eq 'Universal' -and $_.DistinguishedName -notlike "*,DC=$($gc.Domain -split '\.' -join ',DC=')")})

$small=@($groups | ?{($_.GroupScope -eq 'Global') -or ($_.GroupScope -eq 'Universal' -and $_.DistinguishedName -like "*,DC=$($gc.Domain -split '\.' -join ',DC=')")})

$tokenSize=1200 + (40 * $large.Count) + (8 * $small.Count)

if($ID.SIDHistory)
   { $tokenSize += 40 * $user.SIDHistory.Count }
if($tokenSize -lt 65535)
   { Write-Host "The token size $($tokenSize)kb for GID $ID is under the MaxTokenSize of 65535kb.`n" }

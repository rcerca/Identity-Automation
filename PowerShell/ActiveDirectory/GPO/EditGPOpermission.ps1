$X = "AAA", "XXX", "YYY", "ZZZ"
foreach ($X in $x)
{
  $perms = Foreach ($GPO in (Get-GPO -All | ?{$_.DisplayName -like "$X*"}))
             {
               Foreach ($Perm in (Get-GPPermissions $GPO.DisplayName -All | Where {$_.Permission -eq "GpoEdit"})) 
                   { New-Object PSObject -property @{GPO=$GPO.DisplayName;Trustee=$Perm.Trustee.Name;Permission=$Perm.Permission} }
             }
  $perms | Select GPO,Trustee,Permission
}

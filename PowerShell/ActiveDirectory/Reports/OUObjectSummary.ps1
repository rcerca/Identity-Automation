Clear

$Pool = "OU1","OU2","OU3"

$Results = foreach ($P in $Pool) {

    $OU = Get-ADOrganizationalUnit -Filter "Name -eq '$P'" |
          Select-Object -ExpandProperty DistinguishedName

    if (-not $OU) {
        [PSCustomObject]@{
            Site        = $P
            OU          = "Not Found"
            Computers   = "N/A"
            Users       = "N/A"
        }
        continue
    }

    $WorkstationsOU = "OU=Workstations,$OU"
    $UsersOU        = "OU=Users,$OU"

    $CompCount  = (Get-ADComputer -Filter * -SearchBase $WorkstationsOU -ErrorAction SilentlyContinue).Count
    $UserCount  = (Get-ADUser     -Filter * -SearchBase $UsersOU        -ErrorAction SilentlyContinue).Count

    [PSCustomObject]@{
        OU          = $P
        OUPath      = $OU
        Computers   = $CompCount
        Users       = $UserCount
    }
}

$Results | Sort-Object OU | Format-Table -AutoSize

    Clear
    $X = get-adgroup -filter {name -like "*GroupName*"} -pr memberof | select name, @{n=’MemberOf’; e= { ( $_.memberof | % { (Get-ADObject $_).Name }) }}
    $ResultsArray = @()
    foreach ($y in $X)
    {
     foreach($z in $y.memberof){
     $RA = New-Object PSObject
     $RA | Add-Member -type NoteProperty -name "Name"   -Value $y.name
     $RA | Add-Member -type NoteProperty -name "MemberOf" -Value $Z
     $ResultsArray += $RA}
    }
$ResultsArray # | Export-Csv -Path C:\FileName.csv -NoTypeInformation





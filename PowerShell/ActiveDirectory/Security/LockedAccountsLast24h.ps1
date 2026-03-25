$DCs   = Get-ADDomainController -Filter *
$Since = (Get-Date).AddHours(-24)

Write-Host "`nSearching for locked accounts in the last 24 hours...`n"

$LockedAccounts = foreach ($dc in $DCs) {

    Get-WinEvent -ComputerName $dc.HostName `
        -LogName Security `
        -FilterXPath "*[System[EventID=4740]]" `
        -ErrorAction SilentlyContinue |
    Where-Object { $_.TimeCreated -ge $Since } |
    ForEach-Object {
        $xml = [xml]$_.ToXml()

        [pscustomobject]@{
            TimeCreated      = $_.TimeCreated
            DomainController = $dc.HostName
            LockedOutUser    = $xml.Event.EventData.Data |
                               Where-Object { $_.Name -eq 'TargetUserName' } |
                               Select-Object -ExpandProperty '#text'
            CallerComputer   = $xml.Event.EventData.Data |
                               Where-Object { $_.Name -eq 'CallerComputerName' } |
                               Select-Object -ExpandProperty '#text'
        }
    }
}

$LockedAccounts | Sort-Object TimeCreated | Format-Table -AutoSize

# Ask for the account
$user = Read-Host "Enter the locked out account"

# Get all DCs once and build a lookup by IPv4 address
$Global:DomainControllers = Get-ADDomainController -Filter * |
    Select-Object HostName, IPv4Address, Site

$fqdn = (Get-ADDomain).DNSRoot
$Short = (Get-ADDomain).NetBIOSName

function Resolve {
    param(
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [string]$system
    )

    process {
        $dc = $Global:DomainControllers |
              Where-Object { $_.IPv4Address -eq $system }

        if ($dc) {
            return "$system (Domain Controller - $($dc.Site))"
        }
        else {
            return $system
        }
    }
}

$unique4625 = @()
$unique4740 = @()
$unique4771 = @()
$unique4776 = @()

Write-Host "`nQuerying the event logs for lockouts and failed authentication attempts for $user...`n"

$events = Get-WinEvent -LogName ForwardedEvents `
    -FilterXPath "*[EventData[Data[@Name='TargetUserName'] and (Data='$user')]] 
                  and *[System[(EventID='4625' or EventID='4740' or EventID='4771' or EventID='4776')]]" `
    -ErrorAction SilentlyContinue


   if($events){

      Write-Output "Event ID,Time Created,Account,Message,Status,Sub-Status,Type,Reason,System,Domain Controller"

      $events | %{
         $dc=$_.MachineName -replace ".$($fqdn)",""
         $event=$_.Id
         $time=$_.TimeCreated
         $message=$($($_.Message -split ':\s*') -split '\s{2}')[0]
         $xml = [xml]$_.ToXml()
         $nodes=$xml.Event.EventData.ChildNodes

         if($event -eq "4625"){
            $system=($nodes | ?{$_.Name -eq "IpAddress"}).'#text'
            $account=($nodes | ?{$_.Name -eq "TargetUserName"}).'#text'
            $type=($nodes | ?{$_.Name -eq "LogonType"}).'#text'
            $reason=($nodes | ?{$_.Name -eq "FailureReason"}).'#text'
            $status=($nodes | ?{$_.Name -eq "Status"}).'#text'
            $subStat=($nodes | ?{$_.Name -eq "SubStatus"}).'#text'

            switch($type){
               {$type -eq "2"}{$typeDesc = '"2 - Interactive Logon: This occurs when users logon at the console of a Windows computer."'}
               {$type -eq "3"}{$typeDesc = '"3 - Network Logon: This occurs when users access remote file shares, printers, IIS, etc."'}
               {$type -eq "4"}{$typeDesc = '"4 - Batch Logon: This occurs when a users creds are used for scheduled tasks."'}
               {$type -eq "5"}{$typeDesc = '"5 - Service Logon: This occurs when a users creds are used to start a Windows service."'}
               {$type -eq "7"}{$typeDesc = '"7 - Unlock Logon: This occurs when users logon from a lock screen of a Windows computer."'}
               {$type -eq "8"}{$typeDesc = '"8 - Network Clear Text Logon: This occurs when users logon over the network with clear text password."'}
               {$type -eq "9"}{$typeDesc = '"9 - New Credentials-based Logon: This occurs when users run an application using the RunAs command and specify the /netonly switch."'}
               {$type -eq "10"}{$typeDesc = '"10 - Remote Interactive Logon: This occurs when users logon to RDP-based applications like Terminal Services, Remote Desktop or Remote Assistance."'}
               {$type -eq "11"}{$typeDesc = '"11 - Cached Interactive Logon: This occurs when users log on using cached credentials."'}
               default{$typeDesc = $type}
            }

            switch($reason){
               {$reason -eq "%%2304"}{$reasonDesc = '"2304 - An error occurred during Logon."'}
               {$reason -eq "%%2305"}{$reasonDesc = '"2305 - The specified user account has expired."'}
               {$reason -eq "%%2307"}{$reasonDesc = '"2307 - Account locked out."'}
               {$reason -eq "%%2309"}{$reasonDesc = '"2309 - The specified accounts password has expired."'}
               {$reason -eq "%%2310"}{$reasonDesc = '"2310 - Account currently disabled."'}
               {$reason -eq "%%2312"}{$reasonDesc = '"2312 - User not allowed to logon at this computer."'}
               {$reason -eq "%%2313"}{$reasonDesc = '"2313 - Unknown user name or bad password."'}
               default{$reasonDesc = $reason}
            }

            switch($status){
               {$status -eq "0xC000005E"}{$statusDesc = '"0xC000005E - There are currently no logon servers available to service the logon request."'}
               {$status -eq "0xC0000064"}{$statusDesc = '"0xC0000064 - User logon with misspelled or bad user account."'}
               {$status -eq "0xC000006A"}{$statusDesc = '"0xC000006A - User logon with misspelled or bad password."'}
               {$status -eq "0xC000006D"}{$statusDesc = '"0xC000006D - This is either due to a bad username or authentication information."'}
               {$status -eq "0xC000006E"}{$statusDesc = '"0xC000006E - Unknown user name or bad password."'}
               {$status -eq "0xC000006F"}{$statusDesc = '"0xC000006F - User logon outside authorized hours."'}
               {$status -eq "0xC0000070"}{$statusDesc = '"0xC0000070 - User logon from unauthorized workstation."'}
               {$status -eq "0xC0000071"}{$statusDesc = '"0xC0000071 - User logon with expired password."'}
               {$status -eq "0xC0000072"}{$statusDesc = '"0xC0000072 - User logon to account disabled by administrator."'}
               {$status -eq "0xC00000DC"}{$statusDesc = '"0xC00000DC - Indicates the Sam Server was in the wrong state to perform the desired operation."'}
               {$status -eq "0xC0000133"}{$statusDesc = '"0xC0000133 - Clocks between DC and other computer too far out of sync."'}
               {$status -eq "0xC000015B"}{$statusDesc = '"0xC000015B - The user has not been granted the requested logon type (aka logon right) at this machine."'}
               {$status -eq "0xC000018C"}{$statusDesc = '"0xC000018C - The logon request failed because the trust relationship between the primary domain and the trusted domain failed."'}
               {$status -eq "0xC0000192"}{$statusDesc = '"0xC0000192 - An attempt was made to logon, but the Netlogon service was not started."'}
               {$status -eq "0xC0000193"}{$statusDesc = '"0xC0000193 - User logon with expired account."'}
               {$status -eq "0xC0000224"}{$statusDesc = '"0xC0000224 - User is required to change password at next logon."'}
               {$status -eq "0xC0000225"}{$statusDesc = '"0xC0000225 - Evidently a bug in Windows and not a risk."'}
               {$status -eq "0xC0000234"}{$statusDesc = '"0xC0000234 - User logon with account locked."'}
               {$status -eq "0xC00002EE"}{$statusDesc = '"0xC00002EE - Failure Reason: An Error occurred during Logon."'}
               {$status -eq "0xC0000413"}{$statusDesc = '"0xC0000413 - The machine you are logging onto is protected by an authentication firewall."'}
               default{$statusDesc = $status}
            }

            switch($subStat){
               {$subStat -eq "0xC000005E"}{$subStatDesc = '"0xC000005E - There are currently no logon servers available to service the logon request."'}
               {$subStat -eq "0xC0000064"}{$subStatDesc = '"0xC0000064 - User logon with misspelled or bad user account."'}
               {$subStat -eq "0xC000006A"}{$subStatDesc = '"0xC000006A - User logon with misspelled or bad password."'}
               {$subStat -eq "0xC000006D"}{$subStatDesc = '"0xC000006D - This is either due to a bad username or authentication information."'}
               {$subStat -eq "0xC000006E"}{$subStatDesc = '"0xC000006E - Unknown user name or bad password."'}
               {$subStat -eq "0xC000006F"}{$subStatDesc = '"0xC000006F - User logon outside authorized hours."'}
               {$subStat -eq "0xC0000070"}{$subStatDesc = '"0xC0000070 - User logon from unauthorized workstation."'}
               {$subStat -eq "0xC0000071"}{$subStatDesc = '"0xC0000071 - User logon with expired password."'}
               {$subStat -eq "0xC0000072"}{$subStatDesc = '"0xC0000072 - User logon to account disabled by administrator."'}
               {$subStat -eq "0xC00000DC"}{$subStatDesc = '"0xC00000DC - Indicates the Sam Server was in the wrong state to perform the desired operation."'}
               {$subStat -eq "0xC0000133"}{$subStatDesc = '"0xC0000133 - Clocks between DC and other computer too far out of sync."'}
               {$subStat -eq "0xC000015B"}{$subStatDesc = '"0xC000015B - The user has not been granted the requested logon type (aka logon right) at this machine."'}
               {$subStat -eq "0xC000018C"}{$subStatDesc = '"0xC000018C - The logon request failed because the trust relationship between the primary domain and the trusted domain failed."'}
               {$subStat -eq "0xC0000192"}{$subStatDesc = '"0xC0000192 - An attempt was made to logon, but the Netlogon service was not started."'}
               {$subStat -eq "0xC0000193"}{$subStatDesc = '"0xC0000193 - User logon with expired account."'}
               {$subStat -eq "0xC0000224"}{$subStatDesc = '"0xC0000224 - User is required to change password at next logon."'}
               {$subStat -eq "0xC0000225"}{$subStatDesc = '"0xC0000225 - Evidently a bug in Windows and not a risk."'}
               {$subStat -eq "0xC0000234"}{$subStatDesc = '"0xC0000234 - User logon with account locked."'}
               {$subStat -eq "0xC00002EE"}{$subStatDesc = '"0xC00002EE - Failure Reason: An Error occurred during Logon."'}
               {$subStat -eq "0xC0000413"}{$subStatDesc = '"0xC0000413 - The machine you are logging onto is protected by an authentication firewall."'}
               default{$subStatDesc = $subStat}
            }

            if(($system -ne $null) -and ($system -ne "") -and ($system -ne " ") -and ($system -ne "-") -and ($system -ne $short)){
               if($unique4625 -notcontains $($system)){
                  $unique4625 += $($system)
               }
            }
         }

         if($event -eq "4740"){
            $system=($nodes | ?{$_.Name -eq "TargetDomainName"}).'#text'
            $account=($nodes | ?{$_.Name -eq "TargetUserName"}).'#text'
            $typeDesc="NULL"
            $reasonDesc="NULL"
            $statusDesc="NULL"
            $subStatDesc="NULL"
            
            if(($system -ne $null) -and ($system -ne "") -and ($system -ne " ") -and ($system -ne "-") -and ($system -ne $short)){
               if($unique4740 -notcontains $($system)){
                  $unique4740 += $($system)
               }
            }
         }

         if($event -eq "4771"){
            $system=(($nodes | ?{$_.Name -eq "IpAddress"}).'#text' -split 'f:')[1]
            $account=($nodes | ?{$_.Name -eq "TargetUserName"}).'#text'
            $type=($nodes | ?{$_.Name -eq "PreAuthType"}).'#text'
            $reason=($nodes | ?{$_.Name -eq "Status"}).'#text'
            $statusDesc="NULL"
            $subStatDesc="NULL"

         switch($type){
            {$type -eq "0"}{$typeDesc = "0 - Logon without Pre-Authentication."}
            {$type -eq "2"}{$typeDesc = "2 - This is a normal type for standard password authentication."}
            {$type -eq "11"}{$typeDesc = "11 - ETYPE-INFO: Usually used to notify a client of which key to use for the encryption of an encrypted timestamp."}
            {$type -eq "15"}{$typeDesc = "15 - Used for Smart Card logon authentication."}
            {$type -eq "17"}{$typeDesc = "17 - This type should also be used for Smart Card authentication, but in certain Active Directory environments, it is never seen."}
            {$type -eq "19"}{$typeDesc = "19 - ETYPE-INFO2: Usually used to notify a client of which key to use for the encryption of an encrypted timestamp."}
            {$type -eq "20"}{$typeDesc = "20 - Used in KDC Referrals tickets."}
            {$type -eq "138"}{$typeDesc = "138 - Logon using Kerberos Armoring (FAST). Supported starting from Windows Server 2012."}
            default{$typeDesc = $type}
         }

         switch($reason){
            {$reason -eq "0x10"}{$reasonDesc = "0x10 - Smart card logon is being attempted and the proper certificate cannot be located."}
            {$reason -eq "0x12"}{$reasonDesc = "0x10 - Client credentials have been revoked."}
            {$reason -eq "0x17"}{$reasonDesc = "0x17 - The user’s password has expired."}
            {$reason -eq "0x18"}{$reasonDesc = "0x18 - The wrong password was provided."}
            default{$reasonDesc = $reason}
         }
         }

            if(($system -ne $null) -and ($system -ne "") -and ($system -ne " ") -and ($system -ne "-") -and ($system -ne $short)){
               if($unique4771 -notcontains $($system)){
                  $unique4771 += $($system)
               }
            }

         if($event -eq "4776"){
            $system=($nodes | ?{$_.Name -eq "Workstation"}).'#text'
            $account=($nodes | ?{$_.Name -eq "TargetUserName"}).'#text'
            $typeDesc="NULL"
            $reason=($nodes | ?{$_.Name -eq "Status"}).'#text'
            $statusDesc="NULL"
            $subStatDesc="NULL"

         switch($reason){
            {$reason -eq "0xC0000064"}{$reasonDesc = "0xC0000064 - User name does not exist."}
            {$reason -eq "0xC000006A"}{$reasonDesc = "0xC000006A - User name is correct but the password is wrong."}
            {$reason -eq "0xC0000234"}{$reasonDesc = "0xC0000234 - User is currently locked out."}
            {$reason -eq "0xC0000072"}{$reasonDesc = "0xC0000072 - Account is currently disabled."}
            {$reason -eq "0xC000006F"}{$reasonDesc = "0xC000006F - User tried to logon outside his day of week or time of day restrictions."}
            {$reason -eq "0xC0000070"}{$reasonDesc = "0xC0000070 - Workstation restriction."}
            {$reason -eq "0xC0000193"}{$reasonDesc = "0xC0000193 - Account expiration."}
            {$reason -eq "0xC0000071"}{$reasonDesc = "0xC0000071 - Expired password."}
            {$reason -eq "0xC0000224"}{$reasonDesc = "0xC0000224 - User is required to change password at next logon."}
            default{$reasonDesc = $reason}
         }

            if(($system -ne $null) -and ($system -ne "") -and ($system -ne " ") -and ($system -ne "-") -and ($system -ne $short)){
               if($unique4776 -notcontains $($system)){
                  $unique4776 += $($system)
               }
            }
         }

         Write-Output "$($event),$($time),$($account),$($message),$($statusDesc),$($subStatDesc),$($typeDesc),$($reasonDesc),$($system),$($dc)"
      }
   
      Write-Host "`r`nThe following event types were found for $($user):`r`n"

      if($unique4625){
         Write-Host "`r`n=== $($unique4625.Count) unique event(s): 4625 - An account failed to log on =========================================`r`n"
         $unique4625 | %{$switch=Resolve($_); Write-Host "$($switch)"}
      }
      if($unique4740){
         Write-Host "`r`n=== $($unique4740.Count) unique event(s): 4740 - A user account was locked out =======================================`r`n"
         $unique4740 | %{$switch=Resolve($_); Write-Host "$($switch)"}
      }
      if($unique4771){
         Write-Host "`r`n=== $($unique4771.Count) unique event(s): 4771 - Kerberos pre-authentication failed =================================`r`n"
         $unique4771 | %{$switch=Resolve($_); Write-Host "$($switch)"}
      }
      if($unique4776){
         Write-Host "`r`n=== $($unique4776.Count) unique event(s): 4776 - The computer attempted to validate the credentials for an account ===`r`n"
         $unique4776 | %{$switch=Resolve($_); Write-Host "$($switch)"}
      }

   }
   else{
      Write-Host "`r`n`r`nNo account lockouts or bad password attempts were found in the event logs.`r`n"
   }

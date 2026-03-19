# Define the list of server names
$servers = @('Server1', 'Server2', 'Server3')
 

# Loop through each session and perform tasks
foreach ($server in $servers) 
{
    $session = New-PSSession -ComputerName $server
    # Example command to run on each server
    Invoke-Command -Session $session -ScriptBlock 
      {
        # Your commands here
        Get-Service
      }

    # Close the sessions when done
    $session | Remove-PSSession
}

Clear

# Define the target user's sAMAccountName (GID)
$ID = "AccountName"

# Create a DirectorySearcher object to query Active Directory
$ds = New-Object System.DirectoryServices.DirectorySearcher

# Search filter: find a user object matching the provided sAMAccountName
$ds.Filter = "(&(objectClass=user)(sAMAccountName=$($ID)))"

# Execute the search and return the first matching result
$sr = $ds.FindOne()

# Convert the search result into a DirectoryEntry object
$user = $sr.GetDirectoryEntry()

# Load the tokenGroups attribute, which contains all security SIDs
$user.RefreshCache(@("tokenGroups"))

# Prepare an array to store translated group names
$groups = @()

# Loop through each SID in tokenGroups
for ($i = 0; $i -lt $user.Properties["tokenGroups"].Count; $i++) {

    # Convert the raw SID bytes into a SecurityIdentifier object
    $sid = New-Object System.Security.Principal.SecurityIdentifier(
        $user.Properties["tokenGroups"][$i], 0
    )

    # Translate the SID into a readable NTAccount (DOMAIN\GroupName)
    $nt = $sid.Translate([System.Security.Principal.NTAccount])

    # Extract only the group name (remove the domain prefix)
    $groups += ($nt -split "\\")[1]
}

# Output the total number of groups in the user's token
$groups.Count

# Output the sorted list of group names
$groups | Sort-Object

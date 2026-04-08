Clear
$Groups = Get-Content C:\Scripts\Ricardo\test.txt | Select-Object -First 1

foreach ($g in $Groups)
{
    # DistinguishedName of the group to modify
    $TargetGroupDN = $g

    # SID of the group receiving permissions
    $DelegateSID = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-21-1557917705-2668330472-1530551649-3884659")

    # Bind to AD object
    $entry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$TargetGroupDN")

    # Get current ACL
    $acl = $entry.ObjectSecurity

    # Rights to grant
    $rights = [System.DirectoryServices.ActiveDirectoryRights] "ReadProperty, WriteProperty" #Below there is the full list of values 
    $controlType = [System.Security.AccessControl.AccessControlType]::Allow
    $inheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None
    $objectType = [Guid]::Empty

    # Build the access rule using the SAFE constructor
    $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
        ($DelegateSID, $rights, $controlType, $objectType, $inheritanceType)

    # Add the rule
    $acl.AddAccessRule($rule)

    # Save back to AD
    $entry.ObjectSecurity = $acl
    $entry.CommitChanges()

    Write-Host "Permissions applied to $TargetGroupDN"
}

<###################################################################
 
Full List of ActiveDirectoryRights Values
Each value controls a different type of permission on an AD object.

-Standard Rights
CreateChild — Create child objects
DeleteChild — Delete child objects
ListChildren — View child objects
Self — Perform validated writes
ReadProperty — Read attributes
WriteProperty — Write attributes
DeleteTree — Delete an entire subtree
ListObject — View object even without list rights
ExtendedRight — Use extended rights (e.g., reset password)
Delete — Delete the object
ReadControl — Read permissions (read security descriptor)
WriteDacl — Modify the DACL (permissions)
WriteOwner — Take ownership
Synchronize — Required for some operations
AccessSystemSecurity — Read/modify SACL (auditing)

-Generic Rights
GenericRead — Read all standard properties
GenericWrite — Write all standard properties
GenericExecute — Execute permissions
GenericAll — Full control

-Special Rights
CreateChild
DeleteChild
ListChildren
Self
ReadProperty
WriteProperty
DeleteTree
ListObject
ExtendedRight

-Combined Rights
All — Full control (equivalent to GenericAll) 
<###################################################################>

##### First name
Clear
$fname = Read-Host "Enter the first name"
get-aduser -filter "givenname -like '*$fname*'" -pr Department,subDept,subDeptCode,Title,l | select l,Name,GivenName ,surname,Department,subDept,subDeptCode,Title | sort givenname,l,surname | ft -AutoSize -Wrap

##### Last name
Clear
$sname = Read-Host "Enter the last name"
get-aduser -filter "surname -like '*$sname*'" -pr Department,subDept,subDeptCode,Title,l | select l,Name,GivenName ,surname,Department,subDept,subDeptCode,Title | sort givenname,l,surname | ft -AutoSize -Wrap

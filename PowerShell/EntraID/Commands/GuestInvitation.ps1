$params = @{
             invitedUserEmailAddress = "admin@fabrikam.com"
             inviteRedirectUrl = "http;//muapp.contoso.com"
           }

New-MgInvitation -BodyParameter $params

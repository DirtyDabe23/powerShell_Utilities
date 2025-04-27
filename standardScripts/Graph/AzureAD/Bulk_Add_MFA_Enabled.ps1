$users = Import-CSV -Path C:\Temp\2024_04_04_uniqueParentCompanyDotcomUsers.csv
$members = Get-MGGroupMember -GroupId "276cd6bd-7e8f-483b-9e33-6b6e364bdd50" -All -ConsistencyLevel eventual
$counter = 1
$maxCount = $users.count 

ForEach ($user in $users)

{
    #secureGraph
    #The Tenant ID from App Registrations
    $tenantId = $tenantIDString

    # Construct the authentication URL
    $uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
 
    #The Client ID from App Registrations
    $clientId = $appIDString
 

 
    #The Client ID from certificates and secrets section
    $clientSecret = 'GraphAPI'
 
 
    # Construct the body to be used in Invoke-WebRequest
    $body = @{
        client_id     = $clientId
        scope         = "https://graph.microsoft.com/.default"
        client_secret = $clientSecret
        grant_type    = "client_credentials"
    }
 
    # Get Authentication Token
    $tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing
 
    # Extract the Access Token
    $token = ($tokenRequest.Content | ConvertFrom-Json).access_token
    $secureToken = ConvertTo-SecureString -String $token -AsPlainText -Force
    #connect to graph
    Connect-MGGraph -AccessToken $secureToken -NoWelcome

    $userObjID = (Get-MGUser -UserID $user.user).ID
    $userDispName = (Get-MGUser -UserID $user.user).DisplayName

        If ($user.MFAStatus -eq "Disabled")
        {
            Write-Host "$counter/$maxCount $userDispName MFA is not enabled"
        }
        Else
        {
            Write-Host "$counter/$maxCount $userDispName MFA is enabled"
            If ($userObjID -notin $members.id)
            {
                Write-Host "$counter/$maxCount $userDispName is joining the group"
                New-MgGroupMember -GroupId "276cd6bd-7e8f-483b-9e33-6b6e364bdd50" -DirectoryObjectId $userObjID
            }
            else
            {
                Write-Host "$counter/$maxCount $userDispName is already in the group"
            }
        }
                
    $counter=$counter+1

}
# SIG # Begin signature block#Script Signature# SIG # End signature block







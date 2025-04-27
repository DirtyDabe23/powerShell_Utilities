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
Connect-MGGraph -AccessToken $secureToken

#connect to Exchange Online
$exoCertThumb = "f5fae1b6ead4efdf33c5a79175561763cac5fb16"
$exoAppID = "1f97c81e-f222-4046-967a-5051db6f1ec1"
$exoORG = "uniqueParentCompanyinc.onmicrosoft.com"
		
Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG

#Create the array and set all values to null
$userData = @()

#Enter the office location for the users to pull. This will get all users with their office location equalling your input. It is not case sensitive, but a trailing space will break things.
$officeLocation = Read-Host -Prompt "Enter The Office Location to review user groups"

#Return all users who's office location matches the entered value 
$Users = Get-MGBetaUser -All | Where-Object {($_.OfficeLocation -eq $officeLocation)}

#For individual users in all of the returned users
ForEach ($user in $users)
{
    #Get all groups that the user is a member of, this is returned as IDs
    $Groups = Get-MGUserMemberOf -userID $user.UserPrincipalName -consistencylevel eventual -All
    
    #Individual Group
    ForEach ($group in $groups)
    {
    #Get readable data returned about the user group
    $groupData = Get-MGGroup -GroupID $group.ID
    
    #Add the following data to custom object, the user's display name, their user principal name, the group display name, and the group description.
    $userData += [PSCustomObject]@{
        DisplayName       = $user.DisplayName
        UserPrincipalName = $user.UserPrincipalName
        GroupName        = $groupData.DisplayName
        GroupDescription = $groupData.description
        }
    
    }

}

#Export the CSV to a temp directory, naming the file after what office location was reviewed.
$userData | Export-CSV -Path "C:\Temp\$officeLocation.UserGroups.csv"
# SIG # Begin signature block#Script Signature# SIG # End signature block









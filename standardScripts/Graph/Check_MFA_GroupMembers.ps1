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
Write-Host "Enter the Domain to check. Example = @uniqueParentCompany.com"
$Domain = Read-Host "Enter the Domain to check"

$users = Get-MGBetaUser -all -consistencylevel eventual | Where-object {($_.CompanyName -ne "Not Affiliated") -and ($_.UserPrincipalName -like "*$domain")}
Write-Host "Checking $($users.count) users for MFA Enabled Group Membership"

#GroupID is for MFA Enabled
$groupMembers = Get-MgGroupMember -groupid "276cd6bd-7e8f-483b-9e33-6b6e364bdd50" -all -ConsistencyLevel eventual

$members = @()

ForEach ($ID in $groupMembers.ID)
{
        $groupUser  = Get-MGBetaUser -userid $ID  
        $members +=[PSCustomObject]@{ 
        UserDisplayName = $gorupUser.DisplayName
        UPN = $groupuser.UserPrincipalName
        Office = $groupuser.OfficeLocation
        Company = $groupuser.companyName
        
        }
}
Write-Host "Enter a path for your file. Example's are C:\Temp\2024_03_25_Export.csv, the full path and file extension are required"
$Path = Read-Host "Path"
$nonMembers | Export-CSV -Path $Path 
# SIG # Begin signature block#Script Signature# SIG # End signature block








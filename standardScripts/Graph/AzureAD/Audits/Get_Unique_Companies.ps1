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


$allAADUsers = Get-MGBetaUser -All -ConsistencyLevel eventual | Where-Object {($_.OnPremisesSyncEnabled -ne $true) -and ($_.UserType -eq "member")}
$allUniqueCompanyNames = $allAADUsers | Sort-Object -Property CompanyName -Unique | Select-Object -Property CompanyName 



$companyNameData = @()


ForEach ($indvCompanyName in $allUniqueCompanyNames)
{
$companyNameVal = $indvCompanyName.companyname
$companyNameCount = $allAADUsers | Where-Object {($_.CompanyName -eq $companyNameVal)}

$companyNameData += [PSCustomObject]@{
        CompanyName    = $companyNameVal
        UserCount       = $companyNameCount.count

}
}

$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$locName = "CompanyName_Counts"

$fileName = $Date+"."+$locName+".csv"

$jobTitleData | Export-CSV -path "C:\Temp\$fileName"
# SIG # Begin signature block#Script Signature# SIG # End signature block








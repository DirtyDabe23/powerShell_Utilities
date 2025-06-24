#secureGraph
#The Tenant ID from App Registrations
$tenantId = "graphTenantID"

# Construct the authentication URL
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
 
#The Client ID from App Registrations
$clientId = "graphAppID"
 

 
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
$exoORG = "parentCompanyinc.onmicrosoft.com"
		
Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG

$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$locName = "AllMGUsers"


$users = Import-CSV -Path "C:\temp\2023.10.24.10.27.AllMGUsers.csv"

ForEach ($user in $users)
{
    If ($user.CompanyName -eq "parentCompany Alcoil Inc")
    {
    Write-Host "$($user.DisplayName) company name is being updated"
    Update-MGUser -UserId $user.UserPrincipalName -CompanyName "parentCompany Alcoil, Inc." 
    }

    If ($user.CompanyName -eq "parentCompany Alcoil, Inc")
    {
    Write-Host "$($user.DisplayName) company name is being updated"
    Update-MGUser -UserId $user.UserPrincipalName -CompanyName "parentCompany Alcoil, Inc." 
    }

     If ($user.CompanyName -eq "parentCompany-Alcoil")
    {
    Write-Host "$($user.DisplayName) company name is being updated"
    Update-MGUser -UserId $user.UserPrincipalName -CompanyName "parentCompany Alcoil, Inc." 
    }


    If ($user.CompanyName -eq "Refrigeration Vessels & Systems")
    {
    Write-Host "$($user.DisplayName) company name is being updated"
    Update-MGUser -UserId $user.UserPrincipalName -CompanyName "subsidiaryCompany1" 
    }

    If ($user.CompanyName -eq "Refrigeration Vessels & Systems, Corp.")
    {
    Write-Host "$($user.DisplayName) company name is being updated"
    Update-MGUser -UserId $user.UserPrincipalName -CompanyName "subsidiaryCompany1" 
    }

    If ($user.CompanyName -eq "Refrigeration Vessels and Systems")
    {
    Write-Host "$($user.DisplayName) company name is being updated"
    Update-MGUser -UserId $user.UserPrincipalName -CompanyName "subsidiaryCompany1" 
    }

     If ($user.CompanyName -eq "Refrigeration Vessels and Systems, Corp.")
    {
    Write-Host "$($user.DisplayName) company name is being updated"
    Update-MGUser -UserId $user.UserPrincipalName -CompanyName "subsidiaryCompany1" 
    }


    If ($user.CompanyName -eq "Refrigeration Vessles & Systems, Corp.")
    {
    Write-Host "$($user.DisplayName) company name is being updated"
    Update-MGUser -UserId $user.UserPrincipalName -CompanyName "subsidiaryCompany1" 
    }


    If ($user.CompanyName -eq "subsidiaryCompany1-shortName")
    {
    Write-Host "$($user.DisplayName) company name is being updated"
    Update-MGUser -UserId $user.UserPrincipalName -CompanyName "subsidiaryCompany1" 
    }

    If ($user.CompanyName -eq "parentCompany Select")
    {
    Write-Host "$($user.DisplayName) company name is being updated"
    Update-MGUser -UserId $user.UserPrincipalName -CompanyName "parentCompany Select Technologies, INC." 
    }


    If ($user.CompanyName -eq "parentCompany Select Tech")
    {
    Write-Host "$($user.DisplayName) company name is being updated"
    Update-MGUser -UserId $user.UserPrincipalName -CompanyName "parentCompany Select Technologies, INC." 
    }

    If ($user.CompanyName -eq "Tower Componenets, Inc")
    {
    Write-Host "$($user.DisplayName) company name is being updated"
    Update-MGUser -UserId $user.UserPrincipalName -CompanyName "subsidiaryCompany4" 
    }


    If ($user.CompanyName -eq "Tower Components, Inc")
    {
    Write-Host "$($user.DisplayName) company name is being updated"
    Update-MGUser -UserId $user.UserPrincipalName -CompanyName "subsidiaryCompany4" 
    }

     If ($user.CompanyName -eq "parentCompany Dry Cooling, Inc")
    {
    Write-Host "$($user.DisplayName) company name is being updated"
    Update-MGUser -UserId $user.UserPrincipalName -CompanyName "parentCompany Dry Cooling, Inc." 
    }

     If ($user.CompanyName -eq "subsidiaryCompany2, Inc")
    {
    Write-Host "$($user.DisplayName) company name is being updated"
    Update-MGUser -UserId $user.UserPrincipalName -CompanyName "subsidiaryCompany2, Inc." 
    }

}

$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$locName = "AllMGUsers"

$fileName = $Date+"."+$locName+".csv"



$allAADUsers = Get-MGBetaUser -All -ConsistencyLevel eventual | Where-Object {($_.OnPremisesSyncEnabled -eq $null) -and ($_.UserType -eq "member")}
$props = $allAADUsers | select-object -Property "DisplayName","UserPrincipalName", "CompanyName", "Country", "OfficeLocation", "BusinessPhones", "UsageLocation"
$props | export-csv -path C:\Temp\$filename


SignatureBlock


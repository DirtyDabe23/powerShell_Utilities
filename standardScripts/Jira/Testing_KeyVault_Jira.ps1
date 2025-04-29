#$jiraAPIKeyKey
$vaultName = 'jiraAPIKeyKey'
$apiVersion = "2020-06-01"
$resource = "https://vault.azure.net"
$endpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT,$resource,$apiVersion
$jiraSecretFile = ""
try
{
    Invoke-WebRequest -Method GET -Uri $endpoint -Headers @{Metadata='True'} -UseBasicParsing
}
catch
{
    $wwwAuthHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
    if ($wwwAuthHeader -match "Basic realm=.+")
    {
        $jiraSecretFile = ($wwwAuthHeader -split "Basic realm=")[1]
    }
}
Write-Host "Secret file path: " $jiraSecretFile`n
$jiraSecret = Get-Content -Raw $jiraSecretFile
$response = Invoke-WebRequest -Method GET -Uri $endpoint -Headers @{Metadata='True'; Authorization="Basic $jiraSecret"} -UseBasicParsing
if ($response)
{
    $jiraToken = (ConvertFrom-Json -InputObject $response.Content).access_token
}

$retrSecret = (Invoke-RestMethod -Uri "https://PREFIX-vault.vault.azure.net/secrets/$($vaultName)?api-version=2016-10-01" -Method GET -Headers @{Authorization="Bearer $jiraToken"}).value


#Jira
$jiraText = "$userName@uniqueParentCompany.com:$retrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$headers = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}



#Pull Jira Ticket Info:
#Connecting to Jira and pulling ticketing information into variables
$TicketNum = Read-Host -Prompt "Enter the Ticket Number (Ex: GHD-2157)"
$Form = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$TicketNum" -Headers $headers
$NewForm = ConvertTo-Json $Form
$NewForm2 = ConvertFrom-Json $NewForm
$uData = $NewForm2.fields

Write-Host $uData


# SIG # Begin signature block#Script Signature# SIG # End signature block










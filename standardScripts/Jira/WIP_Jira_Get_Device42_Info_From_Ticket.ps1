#Connection to the Jira API after getting the token from the Key Vault
$jiraVaultName = 'JiraAPI'
$jiraAPIVersion = "2020-06-01"
$jiraResource = "https://vault.azure.net"
$jiraEndpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT,$jiraResource,$jiraAPIVersion
$jiraSecretFile = ""
try
{
    Invoke-WebRequest -Method GET -Uri $jiraEndpoint -Headers @{Metadata='True'} -UseBasicParsing
}
catch
{
    $jiraWWWAuthHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
    if ($jiraWWWAuthHeader -match "Basic realm=.+")
    {
        $jiraSecretFile = ($jiraWWWAuthHeader -split "Basic realm=")[1]
    }
}
$jiraSecret = Get-Content -Raw $jiraSecretFile
$jiraResponse = Invoke-WebRequest -Method GET -Uri $jiraEndpoint -Headers @{Metadata='True'; Authorization="Basic $jiraSecret"} -UseBasicParsing
if ($jiraResponse)
{
    $jiraToken = (ConvertFrom-Json -InputObject $jiraResponse.Content).access_token
}

$jiraRetrSecret = (Invoke-RestMethod -Uri "https://PREFIX-vault.vault.azure.net/secrets/$($jiraVaultName)?api-version=2016-10-01" -Method GET -Headers @{Authorization="Bearer $jiraToken"}).value

#Jira via the API or by Read-Host 
If ($null -eq $jiraRetrSecret)
{
    $jiraRetrSecret = Read-Host "Enter the API Key" -MaskInput
}
else {
    $null
}

#Jira
$jiraText = "$userName@uniqueParentCompany.com:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$headers = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}



#Pull Jira Ticket Info:
#Connecting to Jira and pulling ticketing information into variables
$TicketNum = Read-Host -Prompt "Enter the Ticket Number (Ex: GHD-2157)"
$Issue = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$TicketNum" -Headers $headers

$parentD42 = $issue.fields.customfield_10792 


$subTasks = $issue.fields.subtasks

ForEach ($subTask in $subTasks)
{

    $subTaskKey = $subTask.Key


$payload = @{
    "update" = @{
        "customfield_10792" = @(
        @{"set" = $parentD42})

    }
}



$jsonPayload = $payload | ConvertTo-Json -Depth 10


Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$($subTaskKey)" -Method Put -Body $jsonPayload -Headers $jiraHeaders

}
# SIG # Begin signature block#Script Signature# SIG # End signature block








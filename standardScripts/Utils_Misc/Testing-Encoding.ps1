$azConnection = Connect-AzAccount -Identity
$azConnection | Out-Null
$jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "jiraAPIKey" -AsPlainText
#Jira via the API or by Read-Host 
If ($null -eq $jiraRetrSecret)
{
    $jiraRetrSecret = Read-Host "Enter the API Key" -MaskInput
}
else {
    $null
}

#Jira
$jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$jiraHeader = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}

$jiraAPIKeyBaseURI = "https://parentCompany.atlassian.net/rest"
$jiraAPIKeyEndpoint = "/api/2/search?jql="
$jiraAPIKeyEndpoint = "/api/2/filter/defaultShareScope"
$jql = 'project = GHD AND summary ~ "Onboard Request" AND Status = "Needs Licenses Purchased"'
$encodedJQL = [System.Web.HttpUtility]::UrlEncode($jql)
$uri = $jiraAPIKeyBaseURI , $jiraAPIKeyEndpoint , $encodedJQL -Join ""
Invoke-RestMethod -Method get -uri $uri -Headers $jiraHeader



#Jira
$jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$jiraHeader = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}

$jiraAPIKeyBaseURI = "https://parentCompany.atlassian.net/rest"
$jiraAPIKeyEndpoint = "/api/3/customFieldOption/10787"
$uri = $jiraAPIKeyBaseURI , $jiraAPIKeyEndpoint -join ""
Invoke-RestMethod -Method get -uri $uri -Headers $jiraHeader


#GraphAPI
$baseGraphAPI = "https://graph.microsoft.com/"
$APIVersion = "v1.0/"
$endPoint = "users/"
$target = "$originID"
$uri = $baseGraphAPI , $APIVersion , $endpoint , $target -join ""
Invoke-GraphRequest -Method get -uri $uri -Body $paramsFromTicket 



SignatureBlock


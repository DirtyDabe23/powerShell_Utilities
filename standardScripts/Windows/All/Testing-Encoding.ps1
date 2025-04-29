$azConnection = Connect-AzAccount -Identity
$azConnection | Out-Null
$jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "$vaultName" -Name "$keyName" -AsPlainText
#Jira via the API or by Read-Host 
If ($null -eq $jiraRetrSecret)
{
    $jiraRetrSecret = Read-Host "Enter the API Key" -MaskInput
}
else {
    $null
}

#Jira
$jiraText = "$userEmail", ":", "$jiraRetrSecret" -join ""
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$jiraHeader = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}

$jirAPIBaseURI = "https://parentCompany.atlassian.net/rest"
$jiraAPIEndpoint = "/api/2/search?jql="
$jiraAPIEndpoint = "/api/2/filter/defaultShareScope"
$jql = 'project = ',$projectKey, ' AND summary ~ "Onboard Request" AND Status = "Needs Licenses Purchased"' -join ""
$encodedJQL = [System.Web.HttpUtility]::UrlEncode($jql)
$uri = $jirAPIBaseURI , $jiraAPIEndpoint , $encodedJQL -Join ""
Invoke-RestMethod -Method get -uri $uri -Headers $jiraHeader -ContentType "application/json" -HttpVersion 2.0



#Jira
$jiraText = "$userEmail" ,":", "$jiraRetrSecret" -join ""
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$jiraHeader = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}

$jirAPIBaseURI = "https://parentCompany.atlassian.net/rest"
$jiraAPIEndpoint = "/api/3/customFieldOption/10787"
$uri = $jirAPIBaseURI , $jiraAPIEndpoint -join ""
Invoke-RestMethod -Method get -uri $uri -Headers $jiraHeader


#GraphAPI
$baseGraphAPI = "https://graph.microsoft.com/"
$APIVersion = "v1.0/"
$endPoint = "users/"
$target = "$originID"
$uri = $baseGraphAPI , $APIVersion , $endpoint , $target -join ""
Invoke-GraphRequest -Method get -uri $uri -Body $paramsFromTicket 


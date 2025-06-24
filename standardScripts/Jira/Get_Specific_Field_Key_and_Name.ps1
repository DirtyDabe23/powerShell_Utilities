Clear-Host
#Jira
If ($null -eq $retrSecret)
{
    $retrSecret = Read-Host "Enter the API Key" -MaskInput
}
else {
    $null
}
$jiraText = "david.drosdick@Domain.extension1:$retrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$headers = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}

$Fields = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/field" -Headers $headers

$customName = Read-Host "Enter the field name"
$fields | Where-Object {($_.Name -like "*$customName*")} | Sort-Object -Property Name | Select-Object 'key' , 'name'
SignatureBlock


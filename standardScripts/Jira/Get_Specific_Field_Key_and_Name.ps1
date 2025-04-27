Clear-Host
#Jira
If ($null -eq $retrSecret)
{
    $retrSecret = Read-Host "Enter the API Key" -MaskInput
}
else {
    $null
}
$jiraText = "$userName@uniqueParentCompany.com:$retrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$headers = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}

$Fields = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/field" -Headers $headers

$customName = Read-Host "Enter the field name"
$fields | Where-Object {($_.Name -like "*$customName*")} | Sort-Object -Property Name | Select-Object 'key' , 'name'
# SIG # Begin signature block#Script Signature# SIG # End signature block







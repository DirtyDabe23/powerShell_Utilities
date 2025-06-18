#Token and required information to connect to Jira's API
$Text = ‘$userName@uniqueParentCompany.com:$jiraRetrSecret’
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
$EncodedText = [Convert]::ToBase64String($Bytes)
$EncodedText

#Set the Header
$headers = @{
    "Authorization" = "Basic $EncodedText"
    "Content-Type" = "application/json"
}


#Connecting to Jira and pulling ticketing information into variables
$TicketNum = Read-Host -Prompt "Enter the Ticket Number (Ex: GHD-2157)"
$Form = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$TicketNum" -Headers $headers
$NewForm = ConvertTo-Json $Form
$NewForm2 = ConvertFrom-Json $NewForm
$uData = $NewForm2.fields
# SIG # Begin signature block#Script Signature# SIG # End signature block








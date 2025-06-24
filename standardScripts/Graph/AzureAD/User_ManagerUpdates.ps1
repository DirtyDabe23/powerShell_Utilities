#Token and required information to connect to Jira's API
$Text = ‘david.drosdick@Domain.extension1:$jiraRetrSecret’
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
$Form = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/issue/$TicketNum" -Headers $headers
$NewForm = ConvertTo-Json $Form
$NewForm2 = ConvertFrom-Json $NewForm
$uData = $NewForm2.fields
SignatureBlock


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

#Load the user information array into a variable.
$users = $udata.customfield_10780

#Get the Manager ID
$tempVar = $uData.customfield_10765.displayName
$managerID = (Get-MGUser -Search "DisplayName:$tempvar" -ConsistencyLevel:eventual -top 1).ID

$i = 0


ForEach ($user in $users)
{
    
    $arr = $udata.customfield_10780.Substring(137) -split ";"
    $userEmail = $arr[0]
    Write-Host "User to modify is:" $userEmail
    Write-Host "Manager of user is:" $udata.customfield_10765.emailAddress
    

    $i++

}
# SIG # Begin signature block#Script Signature# SIG # End signature block







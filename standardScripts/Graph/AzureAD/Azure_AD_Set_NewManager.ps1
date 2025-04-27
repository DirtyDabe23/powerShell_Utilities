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

#set the counter to null
$i = 0


ForEach ($user in $users)
{
    #Creates a temporary array, splitting everything after the email address, email addresses start at 137 in the array
    $arr = $udata.customfield_10780[$i].Substring(137) -split ";"
    #Sets the email address to the first part of the array split above
    $userEmail = $arr[0]
    #General Write-Host message to indicate it's running.
    Write-Host "User to modify is:" $userEmail "Manager of user is:" $udata.customfield_10765.emailAddress
    #Sets the Manager
    Set-MgUserManagerByRef -UserId $userEmail `
    -AdditionalProperties @{
         "@odata.id" = "https://graph.microsoft.com/v1.0/users/$ManagerId"
    }

    #Increment the counter to get to the next entry in the array
    $i++

}

# SIG # Begin signature block#Script Signature# SIG # End signature block







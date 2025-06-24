Clear-Host 
$process = "GIT Service Desk & Infrastructure Ticket Review"
#Sets the PowerShell Window Title
$host.ui.RawUI.WindowTitle = $process



#Connect to Jira via the API Secret in the Key Vault
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
$jiraHeader = @{`
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}

[int] $numberofDays = Read-Host "Enter the number of days to review"
[int] $backDate = $numberofDays * -1
$allStartTime = Get-Date 
$backDateDate = (Get-Date).addDays($backDate)
$backDateForm = Get-Date $backDateDate -format yyyy-MM-dd
$currDate = Get-Date -format yyyy-MM-dd
Write-Output "Reviewing Days between $backDateForm and $currDate"

$pageCount = 1
# Initialize variables
$ticketsMatching = @()
$uriTemplate = "https://parentCompany.atlassian.net/rest/api/2/search?jql=project%20in%20(CYOPS,GHD)%20AND%20created%20%3E%3D%20$($backDate)d&startAt={0}"
# Retrieve total issue count
$total = (Invoke-RestMethod -Method Get -Uri ($uriTemplate -f 0) -Headers $jiraHeader).total
$totalPages = $total/50
If (($totalPages%1) -gt 0)
    {
    $totalPages +=1-($totalPages % 1)
    }


# Process issues in batches
for ($count = 0; $count -lt $total; $count += 50) {
    $issuePageStartTime = Get-Date 
    $uri = $uriTemplate -f $count
    $issues = Invoke-RestMethod -Method Get -Uri $uri -Headers $jiraHeader
    foreach ($issue in $issues.issues) {
                    $ticketsMatching += [PSCustomObject]@{
                        DateCreated     = $issue.fields.created
                        TicketNumber    = $issue.key
                        Labels          = $issue.fields.labels
                        issueType       = $issue.fields.issuetype.name
                        requestType     = $issue.fields.customfield_10002.requestType.name
                        Status          = $issue.fields.status.name 
                        Summary         = $issue.fields.summary
                        Description     = $issue.fields.description
                        Assignee        = $issue.fields.assignee.displayname
                        assignEmail     = $issue.fields.assignee.emailaddress
                        reporterDisplayName = $issue.fields.reporter.displayName
                        reporterEmailAddress = $issue.fields.reporter.emailaddress
                        DateFinished   = $issue.fields.resolutiondate
                        AffectedparentCompanyLocation = $issue.fields.customfield_10923.value
                    }

    }
    $issuePageEndTime = Get-Date
    $issuePageNetTime = $issuePageEndTime - $issuePageStartTime
    $currTime = Get-Date -format "HH:mm"
    $issuePageProcess = "Jira Issue Page Review"
    Write-Output "[$($currTime)] | [Total Issuge Pages: $($totalPages)] | Time taken for [$issuePageProcess : Page $pageCount] to complete: $($issuePageNetTime.hours) hours, $($issuePageNetTime.minutes) minutes, $($issuePageNetTime.seconds) seconds"
    $pagecount++
}

# Export the results
$allEndTime = Get-Date 
$allNetTime = $allEndTime - $allStartTime
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | Time taken for [Infrastructure Ticket Audit] to complete: $($allNetTime.hours) hours, $($allNetTime.minutes) minutes, $($allNetTime.seconds) seconds"
$exportPath = "C:\Users\david.drosdick\parentCompany, Inc\GIT IT Support - General\Reports\$(get-date -format yyyy-MM-dd)-cyops-ghd-tickets.csv"
$ticketsMatching | Export-Csv -Path $exportPath -NoTypeInformation



$AffectedparentCompanyLocations = $ticketsMatching | Sort-Object -Property AffectedparentCompanyLocation -Unique | Select-Object -Property AffectedparentCompanyLocation

$AffectedparentCompanyLocations =  $AffectedparentCompanyLocations.AffectedparentCompanyLocation | Select-Object -Unique | Sort-Object

$AffectedparentCompanyLocationsTicketCount = @()

ForEach ($AffectedparentCompanyLocation in $AffectedparentCompanyLocations)
{
   #strip the Office Location value down to the base element
   $AffectedparentCompanyLocationName = $AffectedparentCompanyLocation
   #Get the user count for the individual Given Name  
   $AffectedparentCompanyLocationNameCount = ($ticketsMatching | Where-Object {($_.AffectedparentCompanyLocation -contains $AffectedparentCompanyLocationName)}).count
   $AffectedparentCompanyLocationNameTickets = $ticketsMatching | Where-Object {($_.AffectedparentCompanyLocation -contains $AffectedparentCompanyLocationName)}

   $affectedparentCompanyLocationNameTicketsCustomerRequestTypes = $AffectedparentCompanyLocationNameTickets| Sort-Object -Property requestType -Unique | Select-Object -Property requestType
   
   ForEach ($affectedparentCompanyLocationNameTicketsCustomerRequestType in $affectedparentCompanyLocationNameTicketsCustomerRequestTypes.RequestType)
   {
        $AffectedparentCompanyLocationNameTicketCustomerRequestTypeAssignees = $AffectedparentCompanyLocationNameTickets | Where-Object {($_.RequestType)} | Sort-Object -Property Assignee -Unique | Select-Object -Property Assignee

        ForEach ($AffectedparentCompanyLocationNameTicketCustomerRequestTypeAssignee in $AffectedparentCompanyLocationNameTicketCustomerRequestTypeAssignees.Assignee)
        {
            
                #Write-Output "Affected parentCompany Location Name:$AffectedparentCompanyLocationName `nRequest Type: $affectedparentCompanyLocationNameTicketsCustomerRequestType `nAssignee:  $AffectedparentCompanyLocationNameTicketCustomerRequestTypeAssignee"
                $AELNTCRTA = $TicketsMatching | Where-Object {($_.AffectedparentCompanyLocation -contains $AffectedparentCompanyLocationName) -and ($_.RequestType -eq $affectedparentCompanyLocationNameTicketsCustomerRequestType) -and ($_.Assignee -eq $AffectedparentCompanyLocationNameTicketCustomerRequestTypeAssignee)}
                

                
                Switch ($AffectedparentCompanyLocationName){
                $null{
                $AffectedparentCompanyLocationName = "Unknown"
                }
                }

                Switch ($affectedparentCompanyLocationNameTicketsCustomerRequestType){
                        $null{
                        $affectedparentCompanyLocationNameTicketsCustomerRequestType = "SubTask"
                        }
                        }
                
                Switch ($affectedparentCompanyLocationNameTicketsCustomerRequestType){
                $null{
                $affectedparentCompanyLocationNameTicketsCustomerRequestType = "SubTask"
                }
                }

                $AELNTCRTACount = $AELNTCRTA.Count
                Switch ($AELNTCRTACount){
                        $null{
                            $AELNTCRTACount = 0
                        }
                        }
                
                Switch ($AffectedparentCompanyLocationNameTicketCustomerRequestTypeAssignee){
                        $null{
                        $AffectedparentCompanyLocationNameTicketCustomerRequestTypeAssignee = "Automation for Jira"
                        }
                        }
                        
                
                If ($AELNTCRTACount -ne 0)
                {
                #Add it into the PSCustomObject 
                $AffectedparentCompanyLocationsTicketCount += [PSCustomObject]@{
                        LocationName       = $AffectedparentCompanyLocationName
                        RequestType        =  $affectedparentCompanyLocationNameTicketsCustomerRequestType
                        Assignee = $AffectedparentCompanyLocationNameTicketCustomerRequestTypeAssignee
                        AssigneeCount = $AELNTCRTACount
                        }
                }


        }
   


   }
     

}
Write-Output "The list of all tickets created by Affected parentCompany Location, by Assignee, By Count, in the past $numberofDays days:`n"
$AffectedparentCompanyLocationsTicketCount = $AffectedparentCompanyLocationsTicketCount | sort-object -Property  @{Expression = "AssigneeCount"; Descending = $True}, @{Expression = "LocationName"; Descending = $True} , @{Expression = "Assignee"; Descending = $False} , @{Expression = "RequestType"; Descending = $False}
$AffectedparentCompanyLocationsTicketCount| Out-Host


$parentCompanyLocations = $ticketsMatching | Sort-Object -Property AffectedparentCompanyLocation -Unique | Select-Object -Property AffectedparentCompanyLocation

$baseAffectedparentCompanyLocations =  $parentCompanyLocations.AffectedparentCompanyLocation | Select-Object -Unique | Sort-Object

$locationTicketCount = @()


ForEach ($baseAffectedparentCompanyLocations in $baseAffectedparentCompanyLocations)
{
   #strip the Office Location value down to the base element
   $baseAffectedparentCompanyLocationsName = $baseAffectedparentCompanyLocations
   #Get the user count for the individual Given Name  
   $AffectedparentCompanyLocationNameCount = ($ticketsMatching | Where-Object {($_.AffectedparentCompanyLocation -contains $baseAffectedparentCompanyLocationsName)}).count
   #Add it into the PSCustomObject 
   Switch ($AffectedparentCompanyLocationName){
   $null{
    $AffectedparentCompanyLocationName = "Unknown"
    }
    }
   $locationTicketCount += [PSCustomObject]@{
        AffectedLocationName        = $baseAffectedparentCompanyLocationsName 
        Count                       = $AffectedparentCompanyLocationNameCount
        }
     

}
Write-Output "The list of all tickets created by parentCompany Location in the past $numberofDays days:`n"
$locationTicketCount = $locationTicketCount | sort-object -Property Count -Descending 
$locationTicketCount | Out-Host



$assignees = $ticketsMatching | Sort-Object -Property Assignee -Unique | Select-Object -Property Assignee


$assigneeTicketCount = @()

ForEach ($assignee in $assignees)
{
   #strip the Office Location value down to the base element
   $gName = $assignee.Assignee
   #Get the user count for the individual Given Name  
   $gNameCount = ($ticketsMatching | Where-Object {($_.Assignee -eq $gName) -and $($_.DateFinished -ne $null)}).count
   #Add it into the PSCustomObject
   Switch ($gName){
    $null{
     $gName = "Automation for Jira"
     }
     } 
   $assigneeTicketCount += [PSCustomObject]@{
        Assignee       = $gName 
        CompletedTickets = $gNameCount
        }
     

}
Write-Output "The list for all tickets created within the past $numberofDays days that were closed:`n"
$assigneeTicketCount = $assigneeTicketCount | sort-object -Property CompletedTickets -Descending 
$assigneeTicketCount | Out-Host


#Filtering out for Security Tickets.
$badLabels = "QuarantineRelease","PhishingReport","SecurityEvent","Incident, PhishingReport"
$standardTickets = $ticketsMatching | Where-Object {($_.Labels -notin $badLabels)}
$assignees = $standardTickets  | Sort-Object -Property Assignee -Unique | Select-Object -Property Assignee


$standardAssigneeTicketCount = @()

ForEach ($assignee in $assignees)
{
   #strip the Office Location value down to the base element
   $gName = $assignee.Assignee
   #Get the user count for the individual Given Name  
   $gNameCount = ($standardTickets | Where-Object {($_.Assignee -eq $gName) -and $($_.DateFinished -ne $null)}).count
   #Add it into the PSCustomObject 
   Switch ($gName){
    $null{
     $gName = "Automation for Jira"
     }
     }
   $standardAssigneeTicketCount += [PSCustomObject]@{
        Assignee       = $gName 
        CompletedTickets = $gNameCount
        }
     

}
Write-Output "The list for all non-security tickets created in the past $numberofDays days that were closed:`n"
$standardAssigneeTicketCount = $standardAssigneeTicketCount | sort-object -Property CompletedTickets -Descending
$standardAssigneeTicketCount | Out-Host



$requestTypes = $ticketsMatching | Sort-Object -Property requestType -Unique | Select-Object -Property requestType


$requestTypeTicketCount = @()

ForEach ($requestType in $requestTypes)
{
   #strip the Office Location value down to the base element
   $requestTypeName = $requestType.requestType
   #Get the user count for the individual Given Name  
   $requestTypeNameCount = ($ticketsMatching | Where-Object {($_.requestType -eq $requestTypeName)}).count
   #Add it into the PSCustomObject 
   Switch ($requestTypeName){
   $null{
    $requestTypeName = "Sub-Task"
    }
    }
   $requestTypeTicketCount += [PSCustomObject]@{
        RequestType       = $requestTypeName 
        Count = $requestTypeNameCount
        }
     

}
Write-Output "The list of all tickets created by Request Type:`n"
$requestTypeTicketCount = $requestTypeTicketCount | sort-object -Property Count -Descending 
$requestTypeTicketCount| Out-Host




$requestTypeTicketCountCompleted = @()

ForEach ($requestType in $requestTypes)
{
   #strip the Office Location value down to the base element
   $requestTypeName = $requestType.requestType
   #Get the user count for the individual Given Name  
   $requestTypeNameCount = ($ticketsMatching | Where-Object {($_.requestType -eq $requestTypeName) -and $($_.DateFinished -ne $null)}).count
   #Add it into the PSCustomObject
   Switch ($requestTypeName){
    $null{
     $requestTypeName = "Sub-Task"
     }
     } 
   $requestTypeTicketCountCompleted += [PSCustomObject]@{
        RequestType       = $requestTypeName 
        Count = $requestTypeNameCount
        }
     

}
Write-Output "The list for all tickets created in the past $numberofDays days that were closed:`n"
$requestTypeTicketCountCompleted =  $requestTypeTicketCountCompleted | sort-object -Property Count -Descending 
$requestTypeTicketCountCompleted | Out-Host

Write-Output "Your CSV of the total ticket overview is located at: $exportPath"
SignatureBlock


$errorsToReview = Import-CSV -Path "\\uniqueParentCompanyusers\departments\Public\Tech-Items\Script Configs\devErrors.csv"

ForEach($errorToReview in $errorsToReview)
{
    $errorToReviewSTR = "*"+$errorToReview.StackTraceString + "*"
    $shareLoc = "\\uniqueParentCompanyusers\departments\Public\Tech-Items\scriptLogs\"
    $fileName = "$($errorToReview.ClassName).csv"
    $dateTime = Get-Date -Format yyyy.MM.dd.HH.mm
    $Start_Time = Get-Date 

    #Jira
    $Text = ‘$userName@uniqueParentCompany.com:$jiraRetrSecret’
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $EncodedText = [Convert]::ToBase64String($Bytes)
    $headers = @{
        "Authorization" =   "Basic $EncodedText"
        "Content-Type" =    "application/json"
    }

    [int] $count = 0 
    $uri = "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/search?jql=project%20%3D%20spec%20&startAt=$count"




    #Pull Jira Ticket Info:
    #Connecting to Jira and pulling ticketing information into variables
    $total = (Invoke-RestMethod -Method get -uri $uri -Headers $headers).total



    $ticketsMatching = @();

    While ($count -lt $total)
    {
        $uri = "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/search?jql=project%20%3D%20spec%20&startAt=$count"
        #Jira
        $Text = ‘$userName@uniqueParentCompany.com:$jiraRetrSecret’
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        $EncodedText = [Convert]::ToBase64String($Bytes)
        $headers = @{
            "Authorization" =   "Basic $EncodedText"
            "Content-Type" =    "application/json"
            "maxResults"   =    [int]50
            "startAt"      =    $count
        }

        $issues = Invoke-RestMethod -Method get -uri $uri -Headers $headers
        ForEach ($issue in $issues.issues)
        {
            $TicketNum = $issue.key
            $Form = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$TicketNum" -Headers $headers
            $attachment = $form.fields.attachment | where-Object {($_.FileName -eq 'log.txt')}

            if ($attachment -ne $null)
            {
                $attachmentContent = Invoke-RestMethod -uri $attachment.content -method get -Headers $headers

                If ($attachmentContent.Exception -like $errorToReviewSTR)
                {
                    Write-Output "Detected!"
                    $ticketsMatching += [PSCustomObject]@{
                        key = $issue.Key
                        created = $issue.fields.Created
                                                            }  
                    
                }   
            }
        
            
        }
        
        if (($total - $count) -ge 50) 
        {
            # Process 50 tickets
            $count += 50
        } 
        else 
        {
            # Process the remaining tickets
            $remaining = $total - $count
            # Process $remaining tickets
            $count += $remaining
        }
    }
    $endTime = Get-Date
    $netTime = $endTime - $start_Time
    $currTime = Get-Date -format "HH:mm" 
    Write-Output "[$($currTime)] | Time taken for [$errorToReview Audit] to complete: $($netTime.hours) hours, $($netTime.minutes) minutes, $($netTime.seconds) seconds"
    $exportPath = $shareLoc+$dateTime+"."+$fileName
    $ticketsMatching | Export-CSv -Path $exportPath
}

# SIG # Begin signature block#Script Signature# SIG # End signature block







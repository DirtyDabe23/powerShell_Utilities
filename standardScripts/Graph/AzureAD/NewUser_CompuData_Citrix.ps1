$softwareNeeds = $form.fields.customfield_10747.value
$procProcess = 'CompuData and Citrix Evaluation'
If ($locationHired -eq 'parentCompany East' -and (($softwareNeeds -contains 'Sage') -or ($softwareNeeds -contains 'DocLink')))
{
    try{
    $compuDataGroup1 = Get-ADGroup -Identity "Citrix Cloud W11M Desktop Users" -server 'Domain.extension1'
    $compuDataGroup2 = Get-ADGroup -Identity "DocLink Users" -Server 'Domain.extension1'
    Add-ADGroupMember -identity $compuDataGroup1 -members 
    Add-ADGroupMember -identity $compuDataGroup2 -members  
    }
    Catch{
        $currTime = Get-Date -format "HH:mm"
        $errorLog += [PSCustomObject]@{
        processFailed                   = $procProcess
        timeToFail                      = $currTime
        reasonFailed                    = $error[0] #gets the most recent error
        failedTargetStandardName        = $computerinfo.Name
        failedTargetDNSName             = $computerinfo.DNSHostName
        failedTargetUser                = $computerInfo.Username
        failedTargetWorkGroup           = $computerInfo.Workgroup
        failedTargetDomain              = $computerInfo.Domain
        failedTargetMemory              = $computerInfo.TotalphysicalMemory
        failedTargetChassis             = $computerInfo.ChassisSKUNumber
        failedTargetManufacturer        = $computerInfo.Manufacturer
        failedTargetModel               = $computerInfo.Model

    }
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Failed. Details Below:"
    Write-Output $errorLog
    $errorLogFull = $errorLog | select-object -last 1

# Initialize an array to store formatted content
$jbody = @()

# Loop through each errorLog item and format it as a JSON paragraph
foreach ($errorIndv in $errorLog) {
    $paragraphs = @(
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Process Failed: $($errorIndv.processFailed)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Time Failed: $($errorIndv.timeToFail)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Reason Failed: $($errorIndv.reasonFailed)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Standard Name: $($errorIndv.failedTargetStandardName)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target DNS Name: $($errorIndv.failedTargetDNSName)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target User: $($errorIndv.failedTargetUser)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target WorkGroup: $($errorIndv.failedTargetWorkGroup)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Domain: $($errorIndv.failedTargetDomain)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Memory: $($errorIndv.failedTargetMemory) MB"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Chassis: $($errorIndv.failedTargetChassis)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Manufacturer: $($errorIndv.failedTargetManufacturer)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Model: $($errorIndv.failedTargetModel)"
                }
            )
        }
    )
    
    $jbody += $paragraphs
}

# Create the final JSON payload
$jsonPayload = @{
    body = @{
        type = "doc"
        version = 1
        content = $jbody
    }
    properties = @(
        @{
            key = "sd.public.comment"
            value = @{
                internal = $true
            }
        }
    )
}

# Convert the PowerShell object to a JSON string
$jsonPayloadString = $jsonPayload | ConvertTo-Json -Depth 10

# Perform the API call
try {
    $response = Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/3/issue/$key/comment" -Method Post -Body $jsonPayloadString -Headers $headers
    Write-Output "API call successful: $($response | ConvertTo-Json -Depth 10)"
} catch {
    Write-Output "API call failed: $($_.Exception.Message)"
}



#Make a public comment and transition the ticket to a new status
$jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Automation Failed. UPN: $emailAddr is already in use."
                    }
                }
            ]
        },
    "transition": {
        "id": "981"
    }
}
"@ 
            Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
            continue
    }

}
elseif ($locationHired -ne 'parentCompany East' -and (($softwareNeeds -contains 'Sage') -or ($softwareNeeds -contains 'DocLink')))
{
    try{
                $upn = $emailAddr.Split('@')[0] +"@Domain.extension1"
                #Create the new user here 
                New-ADUser -Enabled $true `
                -name $displayName `
                -Country "US" `
                -DisplayName $displayName `
                -UserPrincipalName $UPN `
                -OfficePhone "14107562600" `
                -Company "Not Affiliated"` 
                -Title "DocLink User"`
                -AccountPassword $password `
                -Department "Service Account" `
                -GivenName $firstName `
                -Office "parentCompany East" `
                -Path "OU=CompuData - External Sage Users - Non-Synching,DC=parentCompany,DC=COM" `
                -Surname $lastName `
                -Server "Domain.extension1" `
                -EmailAddress $email `
                -SamAccountName $acctSAMName -erroraction Stop
    
                $currTime = Get-Date -format "HH:mm"
                $procEndTime = Get-Date
                $procNetTime = $procEndTime - $procStartTime
                Write-Output "[$($currTime)] | [$process] | [$procProcess] to complete: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"
    
                Set-ADUser $acctSAMName -ChangePasswordAtLogon $true -erroraction Stop
    }
    Catch{
        $currTime = Get-Date -format "HH:mm"
        $errorLog += [PSCustomObject]@{
        processFailed                   = $procProcess
        timeToFail                      = $currTime
        reasonFailed                    = $error[0] #gets the most recent error
        failedTargetStandardName        = $computerinfo.Name
        failedTargetDNSName             = $computerinfo.DNSHostName
        failedTargetUser                = $computerInfo.Username
        failedTargetWorkGroup           = $computerInfo.Workgroup
        failedTargetDomain              = $computerInfo.Domain
        failedTargetMemory              = $computerInfo.TotalphysicalMemory
        failedTargetChassis             = $computerInfo.ChassisSKUNumber
        failedTargetManufacturer        = $computerInfo.Manufacturer
        failedTargetModel               = $computerInfo.Model

    }
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Failed. Details Below:"
    Write-Output $errorLog
    $errorLogFull = $errorLog | select-object -last 1

# Initialize an array to store formatted content
$jbody = @()

# Loop through each errorLog item and format it as a JSON paragraph
foreach ($errorIndv in $errorLog) {
    $paragraphs = @(
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Process Failed: $($errorIndv.processFailed)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Time Failed: $($errorIndv.timeToFail)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Reason Failed: $($errorIndv.reasonFailed)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Standard Name: $($errorIndv.failedTargetStandardName)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target DNS Name: $($errorIndv.failedTargetDNSName)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target User: $($errorIndv.failedTargetUser)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target WorkGroup: $($errorIndv.failedTargetWorkGroup)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Domain: $($errorIndv.failedTargetDomain)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Memory: $($errorIndv.failedTargetMemory) MB"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Chassis: $($errorIndv.failedTargetChassis)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Manufacturer: $($errorIndv.failedTargetManufacturer)"
                }
            )
        },
        @{
            type = "paragraph"
            content = @(
                @{
                    type = "text"
                    text = "Failed Target Model: $($errorIndv.failedTargetModel)"
                }
            )
        }
    )
    
    $jbody += $paragraphs
}

# Create the final JSON payload
$jsonPayload = @{
    body = @{
        type = "doc"
        version = 1
        content = $jbody
    }
    properties = @(
        @{
            key = "sd.public.comment"
            value = @{
                internal = $true
            }
        }
    )
}

# Convert the PowerShell object to a JSON string
$jsonPayloadString = $jsonPayload | ConvertTo-Json -Depth 10

# Perform the API call
try {
    $response = Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/3/issue/$key/comment" -Method Post -Body $jsonPayloadString -Headers $headers
    Write-Output "API call successful: $($response | ConvertTo-Json -Depth 10)"
} catch {
    Write-Output "API call failed: $($_.Exception.Message)"
}



#Make a public comment and transition the ticket to a new status
$jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Automation Failed. UPN: $emailAddr is already in use."
                    }
                }
            ]
        },
    "transition": {
        "id": "981"
    }
}
"@ 
            Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
            continue
    }


}

SignatureBlock


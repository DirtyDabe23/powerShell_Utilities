# Assume $errorLog is defined and populated as a list of PSCustomObjects
$errorLog = @(
    [PSCustomObject]@{
        processFailed                   = "ExampleProcess"
        timeToFail                      = "2024-07-21T12:34:56Z"
        reasonFailed                    = "Some error message"
        failedTargetStandardName        = "ComputerName"
        failedTargetDNSName             = "ComputerName.domain.com"
        failedTargetUser                = "Domain\User"
        failedTargetWorkGroup           = "Workgroup"
        failedTargetDomain              = "Domain"
        failedTargetMemory              = "8192"
        failedTargetChassis             = "ChassisSKU"
        failedTargetManufacturer        = "ManufacturerName"
        failedTargetModel               = "ModelName"
    }
)

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
    $response = Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/3/issue/$key/comment" -Method Post -Body $jsonPayloadString -Headers $headers
    Write-Output "API call successful: $($response | ConvertTo-Json -Depth 10)"
} catch {
    Write-Output "API call failed: $($_.Exception.Message)"
}

# SIG # Begin signature block#Script Signature# SIG # End signature block






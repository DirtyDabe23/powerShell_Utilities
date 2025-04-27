$payload = @{
    "update" = @{
        "fields" = @{
        "customfield_10787" = @(
            @{
                "set"  = @(@{
                        "id" = $officeLocationID
                    }
                )
            }
        )
        }
    }
}

# Convert the payload to JSON
$jsonPayload = $payload | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$($procKey)" -Method Put -Body $jsonPayload -Headers $headers

Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/3/issue/$($procKey)" -Method Put -Body $jsonPayload -Headers $headers


{
    "update" : {
        "customfield_11272" : [{"set" : {"value" : "External Customer (Worst)","child": {"value":"Production"}}}]
    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block






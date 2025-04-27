$Text = ‘$userName@uniqueParentCompany.com:$jiraRetrSecret’
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
$EncodedText = [Convert]::ToBase64String($Bytes)
#$EncodedText
$headers = @{
    "Authorization" = "Basic $EncodedText"
    "Content-Type" = "application/json"
}


$key = "GHD-4598"

$Form = Invoke-RestMethod -Method get -uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key/transitions" -Headers $headers


$jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Testing Waiting for Support to Ready for Automation."
                    }
                }
            ]
        },
    "transition": {
        "id": "951"
    }
}
"@ 

Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers


$jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Testing Ready for Automation to Ready for Service Desk."
                    }
                }
            ]
        },
    "transition": {
        "id": "961"
    }
}
"@ 

Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers

$jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Testing Ready for Support to In Progress ."
                    }
                }
            ]
        },
    "transition": {
        "id": "971"
    }
}
"@ 
Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers

$jsonPayload = @"
    {
    "update": {
            "comment": [
                {
                    "add": {
                        "body": "Testing In Progress to Cancelled."
                    }
                }
            ]
        },
    "transition": {
        "id": "901"
    }
}
"@ 
Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jsonPayload -Headers $headers
# SIG # Begin signature block#Script Signature# SIG # End signature block







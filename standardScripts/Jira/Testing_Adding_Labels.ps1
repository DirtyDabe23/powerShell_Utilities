# Jira API Setup
$encodedText = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$userName@uniqueParentCompany.com:$jiraRetrSecret"))
$headers = @{
    "Authorization" = "Basic $encodedText"
    "Content-Type"  = "application/json"
}


$errorsToReview = Import-Csv -Path "\\uniqueParentCompanyusers\departments\Public\Tech-Items\Script Configs\devErrors.csv"

$key = "GHD-25859"

ForEach ($tag in $errorstoReview.Tag)
{
    $payload = @{
        "update" = @{
            "labels" = @(@{
                "add" = "$($tag)" # Replace with your label
            })
        }
    }
    


# Convert the payload to JSON
$jsonPayload = $payload | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$($key)?notifyUsers=false" -Method Put -Body $jsonPayload -Headers $headers
}

# SIG # Begin signature block#Script Signature# SIG # End signature block







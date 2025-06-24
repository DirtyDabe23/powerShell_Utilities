# Jira API Setup
$encodedText = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("david.drosdick@Domain.extension1:$jiraRetrSecret"))
$headers = @{
    "Authorization" = "Basic $encodedText"
    "Content-Type"  = "application/json"
}


$errorsToReview = Import-Csv -Path "\\parentCompanyusers\departments\Public\Tech-Items\Script Configs\devErrors.csv"

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

Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$($key)?notifyUsers=false" -Method Put -Body $jsonPayload -Headers $headers
}

SignatureBlock


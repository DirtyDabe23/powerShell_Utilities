param(
    [string]$Key,
    [string]$connectionOrderNumber
)


try {
    # Read from Azure Key Vault using managed identity
    $connection = Connect-AzAccount -Identity
    $connectionRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "ConnectionAPI" -AsPlainText
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage

    $ErrorActionPreference = "Stop"
}

try {
    # Read from Azure Key Vault using managed identity
    $connection = Connect-AzAccount -Identity
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "PREFIX-Vault" -Name "jiraAPIKeyKey" -AsPlainText
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage

    $ErrorActionPreference = "Stop"
}



$connectionAuthURI = "https://api.webqa.moredirect.com/service/rest/auth/oauth2?grant_type=PASSWORD&password=$connectionRetrSecret&username=GIT-CYOPS-Technical%40uniqueParentCompany.com"

# Get Authentication Token
$connectionToken = (Invoke-Restmethod -uri $connectionAuthURI).access_token


# Create headers using the Bearer token for authorization
$connectionHeader = @{
    "Authorization" = "Bearer $connectionToken"  # Bearer token for OAuth2
    "Accept"        = "*/*"  # Adding Accept header for expected response format
}

# Perform GET request to the assets endpoint
$shipmentPages = @()
$shipments = Invoke-RestMethod -Uri "https://api.webqa.moredirect.com/service/rest/listing/shipments" -Headers $connectionHeader -Method Get

$maxPages = $shipments.page.totalpages

$pageCounter = 1 

While ($pageCounter -le $maxPages)
{
    $shipmentPages += $shipments._embedded.entities
    $nextPage = $shipments._links.next.href
    $shipments = Invoke-RestMethod -Uri $nextPage -Headers $connectionHeader -Method Get 
    $pageCounter++

}

$matchingOrder = $shipmentPages | Where-Object {($_.orderNum -eq $connectionOrderNumber)}

If ($null -eq $matchingOrder)
{
    $null
}
Else
{
    If ($MatchingOrder.count -gt 1)
    {
        Write-Output "Multiple Orders Detected"
        ForEach ($order in $matchingOrder)
        {
            $vendorPO = $matchingOrder.PO
            $vendorInvoice = $matchingOrder.invoiceNum
            $vendorOrderDate = $matchingOrder.orderDate
            $vendorShipmentID = $matchingOrder.shipmentID
            $vendorShipDate = $matchingOrder.shipDate
            $vendorTrackingNumber = $matchingOrder.$vendorTrackingNumber
            $vendorTrackingLink = $matchingOrder.trackingUrl
            $payload = @{
                "update" = @{
                    "customfield_10930" = @(@{
                        "set" = "$vendorPO" 
                    })
                    "customfield_10932" = @(@{
                        "set" = "$vendorInvoice" 
                    })
                    "customfield_10933" = @(@{
                        "set" = "$vendorOrderDate" # Replace with your label
                    })
                    "customfield_10934" = @(@{
                        "set" = "$vendorShipmentID" # Replace with your label
                    })
                    "customfield_10935" = @(@{
                        "set" = "$vendorShipDate" # Replace with your label
                    })
                    "customfield_10936" = @(@{
                        "set" = "$vendorTrackingNumber" # Replace with your label
                    })
                    "customfield_10937" = @(@{
                        "set" = "$vendorTrackingLink" # Replace with your label
                    })
                }
            }
            # Convert the payload to JSON
            $jsonPayload = $payload | ConvertTo-Json -Depth 10
            
            #Jira
            $jiraText = "$userName@uniqueParentCompany.com:$jiraRetrSecret"
            $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
            $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
            $jiraHeaders = @{
                "Authorization" = "Basic $jiraEncodedText"
                "Content-Type" = "application/json"
            }
            
            
            Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$($key)" -Method Put -Body $jsonPayload -Headers $jiraHeaders  
        }
    }
    else 
    {
        Write-Output "Single Order"
        $vendorPO = $matchingOrder.PO
        $vendorInvoice = $matchingOrder.invoiceNum
        $vendorOrderDate = $matchingOrder.orderDate
        $vendorShipmentID = $matchingOrder.shipmentID
        $vendorShipDate = $matchingOrder.shipDate
        $vendorTrackingNumber = $matchingOrder.$vendorTrackingNumber
        $vendorTrackingLink = $matchingOrder.trackingUrl
        
    $payload = @{
        "update" = @{
            "customfield_10930" = @(@{
                "set" = "$vendorPO" 
            })
            "customfield_10932" = @(@{
                "set" = "$vendorInvoice" 
            })
            "customfield_10933" = @(@{
                "set" = "$vendorOrderDate" # Replace with your label
            })
            "customfield_10934" = @(@{
                "set" = "$vendorShipmentID" # Replace with your label
            })
            "customfield_10935" = @(@{
                "set" = "$vendorShipDate" # Replace with your label
            })
            "customfield_10936" = @(@{
                "set" = "$vendorTrackingNumber" # Replace with your label
            })
            "customfield_10937" = @(@{
                "set" = "$vendorTrackingLink" # Replace with your label
            })
        }
    }
    # Convert the payload to JSON
    $jsonPayload = $payload | ConvertTo-Json -Depth 10


    #Jira
    $jiraText = "$userName@uniqueParentCompany.com:$jiraRetrSecret"
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeaders = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }


    Invoke-RestMethod -Uri "https://uniqueParentCompany.atlassteamMember.net/rest/api/2/issue/$($key)" -Method Put -Body $jsonPayload -Headers $jiraHeaders
    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block










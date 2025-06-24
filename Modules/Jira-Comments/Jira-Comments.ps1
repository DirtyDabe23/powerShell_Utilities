function Set-PrivateErrorJiraRunbook{
    [CmdletBinding()]
    param(
    [Parameter(Position = 0,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 1,HelpMessage = "Enter the message contents for the Jira Ticket")]
    [string]$message = "An Error has Occured" 
    )
    $privateComment = $true
    #Connect to Jira via the API Secret in the Key Vault
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "jiraAPIKey" -AsPlainText

    #Jira via the API or by Read-Host 
    If ($null -eq $jiraRetrSecret)
    {
        $jiraRetrSecret = Read-Host "Enter the Jira API Key" -MaskInput
    }
    else {
        $null
    }

    #Jira
    $jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    #Testing a replacement for: Set-PrivateErrorJiraRunbook
    #This Constructs the core of the post, making the paragraphs.
    $paragraph = @()
    $line = [Ordered]@{"type"  =   "text"; "text"  =   "$message";}
    $content = @{"content" = @($line);"type" = "paragraph"}
    $paragraph += $content


    #This Constructs the parts that are needed to make a private comment.
    $jiraValue = @{"internal" = $privateComment}
    $jiraProperties = [Ordered]@{key = "sd.public.comment";"value"=$jiraValue}

    #This Constructs the Body 
    $jiraType = [Ordered]@{"type"="doc";"version"=1;"content"=$paragraph}
    $jiraBody = [Ordered]@{"body"=$jiraType;"properties"=@($jiraProperties)}
    $jiraPayload = $jiraBody | ConvertTo-JSON -depth 10
    #This makes the comment and transitions the ticket for Jira.
    Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/3/issue/$jiraTicket/comment" -Method Post -Body $jiraPayload -Headers $jiraHeader

}
function Set-PrivateErrorJira{
    [CmdletBinding()]
    param(
    [Parameter(Position = 0,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 1,HelpMessage = "Enter the message contents for the Jira Ticket")]
    [string]$message = "An Error has Occured" 
    )
    #Connect to Jira via the API Secret in the Key Vault
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "jiraAPIKey" -AsPlainText

    #Jira via the API or by Read-Host 
    If ($null -eq $jiraRetrSecret)
    {
        $jiraRetrSecret = Read-Host "Enter the Jira API Key" -MaskInput
    }
    else {
        $null
    }
    

    #Jira
    $jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    #Testing a replacement for: Set-PrivateErrorJiraRunbook
    #This Constructs the core of the post, making the paragraphs.
    $paragraph = @()
    $line = [Ordered]@{"type"  =   "text"; "text"  =   "$message";}
    $content = @{"content" = @($line);"type" = "paragraph"}
    $paragraph += $content

    #This Constructs the parts that are needed to make a private comment.
    $jiraValue = @{"internal" = $privateComment}
    $jiraProperties = [Ordered]@{key = "sd.public.comment";"value"=$jiraValue}

    #This Constructs the Body 
    $jiraType = [Ordered]@{"type"="doc";"version"=1;"content"=$paragraph}
    $jiraBody = [Ordered]@{"body"=$jiraType;"properties"=@($jiraProperties)}
    $jiraPayload = $jiraBody | ConvertTo-JSON -depth 10
    #This makes the comment and transitions the ticket for Jira.
    Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/3/issue/$jiraTicket/comment" -Method Post -Body $jiraPayload -Headers $jiraHeader

}

function Set-SuccessfulComment{
    [CmdletBinding()]
    param(
    [Parameter(Position = 0,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 1,HelpMessage = "Enter the message contents for the Jira Ticket")]
    [string]$message = "Resolved via automated process. Changes were $ParamsFromTicket `n$extensionAttributes" 
    )
    #Connect to Jira via the API Secret in the Key Vault
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "jiraAPIKey" -AsPlainText

    #Jira via the API or by Read-Host 
    If ($null -eq $jiraRetrSecret)
    {
        $jiraRetrSecret = Read-Host "Enter the Jira API Key" -MaskInput
    }
    else {
        $null
    }

    #Jira
    $jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    #Note, all of the following items below are in fact case sensitive. If they keys are not in the proper case, it will fail.
    #This creates an ordered dictionary, which is required for Jira as it requires the key:value pairs to be in certain cases and order(s)
    $jsonPayload = [Ordered]@{}

    #The following is the item for the Message Itself.
    $body = @{"body" = "$message"}
    $add = @{"add" = $body}
    $comment = @{"comment" = @($add)} 
    $update = @{"update" = $Comment}

    #The following are the item(s) for the transition
    $id = @{"id" = "961"}
    $transition = @{"transition"=$id}

    #This constructs the Payload.
    $jsonPayload += $update
    $jsonPayload += $transition
    $jiraPayload = $jsonPayload | ConvertTo-JSON -Depth 10

    #This makes the comment and transitions the ticket for Jira.
    Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$jiraTicket/transitions" -Method Post -Body $jiraPayload -Headers $jiraHeader
    switch ($Continue){
    $False {$null}
    Default {Continue}
    }
}

function Set-SuccessfulCommentRunbook{
    [CmdletBinding()]
    param(
    [Parameter(Position = 0,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 1,HelpMessage = "Enter the message contents for the Jira Ticket")]
    [string]$message = "Resolved via automated process. Changes were $ParamsFromTicket `n$extensionAttributes" 
    )
    #Connect to Jira via the API Secret in the Key Vault
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "jiraAPIKey" -AsPlainText

    #Jira via the API or by Read-Host 
    If ($null -eq $jiraRetrSecret)
    {
        $jiraRetrSecret = Read-Host "Enter the Jira API Key" -MaskInput
    }
    else {
        $null
    }

    #Jira
    $jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    #Note, all of the following items below are in fact case sensitive. If they keys are not in the proper case, it will fail.
    #This creates an ordered dictionary, which is required for Jira as it requires the key:value pairs to be in certain cases and order(s)
    $jsonPayload = [Ordered]@{}

    #The following is the item for the Message Itself.
    $message = "An Error has occured. Contact GIT For Assistance"
    $body = @{"body" = "$message"}
    $add = @{"add" = $body}
    $comment = @{"comment" = @($add)} 
    $update = @{"update" = $Comment}

    #The following are the item(s) for the transition
    $id = @{"id" = "981"}
    $transition = @{"transition"=$id}

    #This constructs the Payload.
    $jsonPayload += $update
    $jsonPayload += $transition
    $jiraPayload = $jsonPayload | ConvertTo-JSON -Depth 10

    #This makes the comment and transitions the ticket for Jira.
    Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$jiraTicket/transitions" -Method Post -Body $jiraPayload -Headers $jiraHeader
}

function Set-PublicErrorJira{
    [CmdletBinding()]
    param(
    [Parameter(Position = 0,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 1,HelpMessage = "Enter the message contents for the Jira Ticket")]
    [string] $message = "An Error has occured. Contact GIT For Assistance"
    )
    #Connect to Jira via the API Secret in the Key Vault
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "jiraAPIKey" -AsPlainText

    #Jira via the API or by Read-Host 
    If ($null -eq $jiraRetrSecret)
    {
        $jiraRetrSecret = Read-Host "Enter the Jira API Key" -MaskInput
    }
    else {
        $null
    }

    #Jira
    $jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    #Note, all of the following items below are in fact case sensitive. If they keys are not in the proper case, it will fail.
    #This creates an ordered dictionary, which is required for Jira as it requires the key:value pairs to be in certain cases and order(s)
    $jsonPayload = [Ordered]@{}

    #The following is the item for the Message Itself.
    $body = @{"body" = "$message"}
    $add = @{"add" = $body}
    $comment = @{"comment" = @($add)} 
    $update = @{"update" = $Comment}

    #The following are the item(s) for the transition
    $id = @{"id" = "981"}
    $transition = @{"transition"=$id}

    #This constructs the Payload.
    $jsonPayload += $update
    $jsonPayload += $transition
    $jiraPayload = $jsonPayload | ConvertTo-JSON -Depth 10

    #This makes the comment and transitions the ticket for Jira.
    Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$jiraTicket/transitions" -Method Post -Body $jiraPayload -Headers $jiraHeader
}

function Set-LicenseNeedPurchased{
    [CmdletBinding()]
    param(
    [Parameter(Position = 1,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 2,HelpMessage = "Enter the message contents for the Jira Ticket")]
    [string]$message = "Automation failed, $license licenses need purchased"
    )
    #Connect to Jira via the API Secret in the Key Vault
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "jiraAPIKey" -AsPlainText

    #Jira via the API or by Read-Host 
    If ($null -eq $jiraRetrSecret)
    {
        $jiraRetrSecret = Read-Host "Enter the Jira API Key" -MaskInput
    }
    else {
        $null
    }

    #Jira
    $jiraText = "david.drosdick@Domain.extension1:$jiraRetrSecret"
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    #Note, all of the following items below are in fact case sensitive. If they keys are not in the proper case, it will fail.
    #This creates an ordered dictionary, which is required for Jira as it requires the key:value pairs to be in certain cases and order(s)
    $jsonPayload = [Ordered]@{}

    #The following is the item for the Message Itself.
    $body = @{"body" = "$message"}
    $add = @{"add" = $body}
    $comment = @{"comment" = @($add)} 
    $update = @{"update" = $Comment}

    #The following are the item(s) for the transition
    $id = @{"id" = "991"}
    $transition = @{"transition"=$id}

    #This constructs the Payload.
    $jsonPayload += $update
    $jsonPayload += $transition
    $jiraPayload = $jsonPayload | ConvertTo-JSON -Depth 10

    #This makes the comment and transitions the ticket for Jira.
    Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$jiraTicket/transitions" -Method Post -Body $jiraPayload -Headers $jiraHeader
}

function Set-JiraComment{
    [CmdletBinding()]
    param(
    [Parameter(Position = 0,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 1,HelpMessage = "Enter the message contents for the Jira Ticket")]
    [string]$message = "An Error has Occured",
    [Parameter(Position = 2,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
    [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain -join ""),
    [Parameter(Position = 3 , HelpMessage = "Enter your API Key for Jira", Mandatory = $true)]
    [string] $jiraKey,  
    [Parameter (Position = 4 , ParameterSetName = "Private", HelpMessage = "Use `$true if this comment should be private, meaning only available to be viewed by logged in users of the Jira system.`
    `n`nIf this is not set, it will default to `$false")]
    [Bool]$privateComment,
    [Parameter (Position = 4 , ParameterSetName = "Public", HelpMessage = "Use this if you would like to transition the issue to a new status.`n`nThis will default to `$false")]
    [Bool]$transition,
    [Parameter (Position = 5 , ParameterSetName = "Public", HelpMessage = "Enter the transition ID of the status", Mandatory = $true)]
    [string]$transitionID
    )
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    if ($transition){
        #This constructs the payload for a comment with a transition.
        $body = @{"body"="$message"}
        $add = @{"add"=$body}
        $comment = @{"comment"=@($add)}
        #This creates the JSON for a transition.
        $id = [Ordered]@{"id" = $transitionID}
        $jiraBody = [Ordered]@{"update"=$comment;"transition" = $id}
        $uri = "https://parentCompany.atlassian.net/rest/api/2/issue/$jiraTicket/transitions"
    }
    else{
    #This Constructs the core of the post, making the paragraphs. This can only be done on comments that do not transition the ticket.
    $paragraph = @()
    $line = [Ordered]@{"type"  =   "text"; "text"  =   "$message";}
    $content = @{"content" = @($line);"type" = "paragraph"}
    $paragraph += $content
    $jiraType = [Ordered]@{"type"="doc";"version"=1;"content"=$paragraph}
    $uri = "https://parentCompany.atlassian.net/rest/api/3/issue/$jiraTicket/comment"
    }
    if ($privateComment){
        #This Constructs the parts that are needed to make a private comment. This can only be done on comments that do not transition the ticket.
        $jiraValue = @{"internal" = $privateComment}
        $jiraProperties = [Ordered]@{key = "sd.public.comment";"value"=$jiraValue}
        $jiraBody = [Ordered]@{"body"=$jiraType;"properties"=@($jiraProperties)}
    }
    else{
        if ($null -eq $jiraBody){
            #This constructs the payload for a comment without a transition.
            $jiraBody = [Ordered]@{"body"=$jiraType}
        }
    }
    #This constructs the final payload into JSON format for posting to Jira.
    $jiraPayload = $jiraBody | ConvertTo-JSON -depth 10
    $jiraPayload
    #This makes the comment and transitions the ticket for Jira.
    $response = Invoke-RestMethod -Uri $uri -Method Post -Body $jiraPayload -Headers $jiraHeader
    return $response
}
function Get-JiraTransition{
    <#
    .SYNOPSIS
    #This function will return all the transitions available for a given Jira ticket.
    
    .DESCRIPTION
    This function will return all the transitions available for a given Jira ticket. It does so by going to the Jira API and retrieving the available transitions. 
    After the data is returned, specifically review the 'to' property of the transition object. This will give you the available transitions for the ticket.
     
    
    .PARAMETER key
    Enter the Jira Ticket Key to retrieve the transitions for. This is a mandatory parameter.
    
    .PARAMETER jiraUser
    Enter the username of the account that is being used to connect to Jira via the API. It will default to your UserName and UserDNSDomain.
    
    .PARAMETER jiraKey
    Enter your API Key for Jira. This is a mandatory parameter.
    
    .PARAMETER jiraUrlPrefix
    Enter the Jira URL-PREFIX. This is a mandatory parameter. Example: yourcompany for yourcompany.atlassian.net. This is a mandatory parameter.
    
    .EXAMPLE
    Get-JiraTransition -key GHD-53697 -jiraUser "david.drosdick@company.com" -jiraKey $jiraRetrSecret -jiraUrlPrefix "company"
    Get-JiraTransition -key GHD-53697 -jiraKey $jiraRetrSecret -jiraUrlPrefix "company"
    
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 2,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
    [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain -join ""),
    [Parameter(Position = 3 , HelpMessage = "Enter your API Key for Jira", Mandatory = $true)]
    [string] $jiraKey,  
    [Parameter(Position = 4, HelpMessage = "Enter the Jira URL-PREFIX`n`nExample yourcompany for yourcompany.atlassian.net)", Mandatory = $true)]
    [string] $jiraOrg = "parentCompany"
    )
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    $uri = "https://", "$jiraOrg", ".atlassian.net/rest/api/3/issue/$jiraTicket/transitions" -join ""
    $response = Invoke-RestMethod -uri $uri -method Get -headers $jiraHeader
    return $response.transitions
}

function Set-JiraTicketTransition{
#Requires -Version 7.0
    <#
    .SYNOPSIS
    This function will transition a Jira ticket to a new status.
    
    .DESCRIPTION
    This function will transition a Jira ticket to a new status. It does so by going to the Jira API and transitioning the ticket to the new status.
    
    .PARAMETER jiraTicket
    Enter the Jira Ticket Key to transition. This is a mandatory parameter.
    
    .PARAMETER jiraUser
    Enter the username of the account that is being used to connect to Jira via the API. It will default to your UserName and UserDNSDomain.
    
    .PARAMETER jiraKey
    Enter your API Key for Jira. This is a mandatory parameter.
    
    .PARAMETER jiraOrg
    Enter the Jira URL-PREFIX. This is a mandatory parameter. Example: yourcompany for yourcompany.atlassian.net. This is a mandatory parameter.
    
    .PARAMETER transitionID
    Enter the transition ID of the status. This is a mandatory parameter.
    
    .EXAMPLE
    Set-JiraTicketTransition -jiraTicket "GHD-53697" -jiraUser $jiraUser -jiraKey $jiraRetrSecret -jiraOrg "parentCompany" -transitionID "981"
    Set-JiraTicketTransition -jiraTicket "GHD-53697" -jiraKey $jiraRetrSecret -jiraOrg "parentCompany" -transitionID "981"
    .NOTES
    General notes
    This function is used to transition a Jira ticket to a new status. It is used in conjunction with the Get-JiraTransition function to retrieve the available transitions for a given Jira ticket.
    It is important to note that the transition ID must be a valid transition for the ticket. If the transition ID is not valid, the function will throw an error.
    If you are unsure of the transition ID, you can use the Get-JiraTransition function to retrieve the available transitions for the ticket.
#>
    [CmdletBinding()]
    param(
    [Parameter(Position = 0,Mandatory = $true,HelpMessage = "Enter the Jira Ticket Key")]
    [string]$jiraTicket,
    [Parameter(Position = 2,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
    [string] $jiraUser =  ($env:UserName,'@',$env:UserDNSDOmain -join ""),
    [Parameter(Position = 3 , HelpMessage = "Enter your API Key for Jira", Mandatory = $true)]
    [string] $jiraKey,
    [Parameter(Position = 4, HelpMessage = "Enter the Jira URL-PREFIX`n`nExample yourcompany for yourcompany.atlassian.net)", Mandatory = $true)]
    [string] $jiraOrg = "parentCompany",
    [Parameter(Position = 5, HelpMessage = "Enter the transition ID of the status", Mandatory = $true)]
    [string]$transitionID
    )
    #This creates the Jira header for authorization into the API and to return the data in JSON format.
    $jiraText = "$jiraUser",":","$jiraKey" -join ""
    $jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
    $jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
    $jiraHeader = @{
        "Authorization" = "Basic $jiraEncodedText"
        "Content-Type" = "application/json"
    }
    $transitions = Get-JiraTransition -jiraTicket $jiraTicket -jiraUser $jiraUser -jiraKey $jiraKey -jiraOrg $jiraOrg
    if ($transitionID -notin $transitions.id){
        Throw "The transition ID $transitionID is not a valid transition for the ticket $jiraTicket. Please check the transition ID and try again."
    }
    else{
        $transition = @{"transition" =@{"id" = $transitionID}} | ConvertTo-Json -Depth 10
    }
    #This constructs the payload for a transition.
    $uri = "https://", "$jiraOrg", ".atlassian.net/rest/api/3/issue/$jiraTicket/transitions" -join ""
    $response = Invoke-RestMethod -uri $uri -method Post -body $transition -headers $jiraHeader -SslProtocol TLS12 -HttpVersion 2.0
    if ($null -ne $response){
        Write-Host "The transition for the ticket $jiraTicket was successful."
        return $response
    }
    else{
        Throw "The transition for the ticket $jiraTicket failed. Please check the response and try again."
    }
}
SignatureBlock


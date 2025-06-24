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
Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$key/transitions" -Method Post -Body $jiraPayload -Headers $jiraHeader

#Testing a replacement for: Set-PrivateErrorJiraRunbook
#This Constructs the core of the post, making the paragraphs.
$paragraph = @()
$date = Get-Date
$messages = ("Time Failed: $date", "Out of Space","You do not have credentials")
ForEAch ($message in $messages){
    $line = [Ordered]@{"type"  =   "text"; "text"  =   "$message";}
    $content = @{"content" = @($line);"type" = "paragraph"}
    $paragraph += $content
}

#This Constructs the parts that are needed to make a private comment.
$jiraValue = @{"internal" = $privateComment}
$jiraProperties = [Ordered]@{key = "sd.public.comment";"value"=$jiraValue}

#This Constructs the Body 
$jiraType = [Ordered]@{"type"="doc";"version"=1;"content"=$paragraph}
$jiraBody = [Ordered]@{"body"=$jiraType;"properties"=@($jiraProperties)}
$jiraPayload = $jiraBody | ConvertTo-JSON -depth 10
#This makes the comment and transitions the ticket for Jira.
Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/3/issue/$key/comment" -Method Post -Body $jiraPayload -Headers $jiraHeader


SignatureBlock


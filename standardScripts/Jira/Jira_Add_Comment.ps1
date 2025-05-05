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
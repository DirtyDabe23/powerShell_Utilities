$test = "objectID"
$upn = "david.drosdick@Domain.extension1"
$hashArguments =@{
$test = "$upn"
}

Get-AzureADUser @hashArguments
SignatureBlock


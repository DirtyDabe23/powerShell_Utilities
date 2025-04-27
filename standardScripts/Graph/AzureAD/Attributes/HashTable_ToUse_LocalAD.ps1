$test = "objectID"
$upn = "$userName@uniqueParentCompany.com"
$hashArguments =@{
$test = "$upn"
}

Get-AzureADUser @hashArguments
# SIG # Begin signature block#Script Signature# SIG # End signature block







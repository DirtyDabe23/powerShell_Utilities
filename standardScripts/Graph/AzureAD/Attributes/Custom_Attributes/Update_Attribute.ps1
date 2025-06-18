#Update a custom security attribute assignment with a multi-string value for a user
#Attribute Set: 
#Attribute:
#AttributeValue:

$AttributeSet = "uniqueParentCompany"
$Attribute = "WorkLocation"
$AttributeValue = "Office"

$userid = "$userName@uniqueParentCompany.com"

Select-MgProfile -Name "beta"
$customSecurityAttributes = @{
    "$AttributeSet" = @{
        "@odata.type" = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
        "$Attribute" = "$AttributeValue"
    }
}
Update-MgUser -UserId $userId -CustomSecurityAttributes $customSecurityAttributes
# SIG # Begin signature block#Script Signature# SIG # End signature block







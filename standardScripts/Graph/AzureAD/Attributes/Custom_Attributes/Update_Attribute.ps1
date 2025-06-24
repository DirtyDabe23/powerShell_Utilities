#Update a custom security attribute assignment with a multi-string value for a user
#Attribute Set: 
#Attribute:
#AttributeValue:

$AttributeSet = "parentCompany"
$Attribute = "WorkLocation"
$AttributeValue = "Office"

$userid = "david.drosdick@Domain.extension1"

Select-MgProfile -Name "beta"
$customSecurityAttributes = @{
    "$AttributeSet" = @{
        "@odata.type" = "#Microsoft.DirectoryServices.CustomSecurityAttributeValue"
        "$Attribute" = "$AttributeValue"
    }
}
Update-MgUser -UserId $userId -CustomSecurityAttributes $customSecurityAttributes
SignatureBlock


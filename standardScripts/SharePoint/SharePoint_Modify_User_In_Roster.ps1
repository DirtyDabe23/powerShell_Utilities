
	
Connect-PNPOnline -url "https://uniqueParentCompanyinc.sharepoint.com/EmployeeRoster/Location/" -Interactive
Get-PNPList
	
#Get the ID of the user we are trying to edit here
Get-PnPListItem -List "Location Office Employee Roster" 
	
	
#The following command is used to expose all of the values that are set for the user with the specified ID 
	
(Get-PnPListItem -List "Location Office Employee Roster" -ID 455).fieldvalues
	
#FieldName / Key to Modify: JobTitle
	
#The following sets the values in SharePoint, the first entry is the key to modify, the second entry is the value to add/modify 
Set-PnPListItem -List "Location Office Employee Roster" -Identity 455 -Values @{"JobTitle"="GIT System Administrator"} -UpdateType UpdateOverwriteVersion
	
#Modified by field adds my username, which is based off my -interactive login for Connect-PNPOnline 
	
	
#In order for us to make updates to the roster, we will need to have a list of who exists in what roster....
#Location and Work Location are the fields that I will need to review and address
		
#Updating User Field Selector Values:
#https://www.sharepointdiary.com/2017/10/sharepoint-online-get-set-person-or-group-people-picker-field-using-powershell.html
		
#Email_x0020_Address              $userName@uniqueParentCompany.com
		

#search for the user and return all values stored in their entry.
$user = (Get-PnPListItem -List "Location Office Employee Roster").fieldvalues | where-object {$_.Email_x0020_Address -eq "$userName@uniqueParentCompany.com"}
	
#Example of how the user modification would work programmatically	
$toMod = "$userName@uniqueParentCompany.com"
$user = (Get-PnPListItem -List "Location Office Employee Roster").fieldvalues | where-object {$_.Email_x0020_Address -eq $toMod}
	
#Returned parameters are case sensitive.
$user.id -eq $null
$user.ID -neq $null 
# SIG # Begin signature block#Script Signature# SIG # End signature block







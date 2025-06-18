$DistroMembers = Get-DistributionGroupMember -identity "ESOP-PSIP-Distro@uniqueParentCompany.com" -resultsize unlimited
$csvUsers = Import-CSV -path "C:\Users\$userName\OneDrive - uniqueParentCompany, Inc\Documents\_Project\_Distribution_Groups\ESOP\Email_Distribution_List_ESOP_PSIP.csv"

$auditStatus = @()

ForEach ($DistroMember in $DistroMembers)
{
    
   If ($DistroMember.primarySMTPAddress -notin $csvUsers.EmailAddress)
   {
   $auditStatus+= [PSCustomObject]@{
        UserAddress = $DistroMember.primarySMTPAddress
        UserStatus = "Email Not in List provided by Pete"
        }
   } 

}



# SIG # Begin signature block#Script Signature# SIG # End signature block






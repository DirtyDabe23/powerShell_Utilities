$DistroMembers = Get-DistributionGroupMember -identity "ESOP-PSIP-Distro@Domain.extension1" -resultsize unlimited
$csvUsers = Import-CSV -path "C:\Users\David.drosdick\OneDrive - parentCompany, Inc\Documents\_Project\_Distribution_Groups\ESOP\Email_Distribution_List_ESOP_PSIP.csv"

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



SignatureBlock


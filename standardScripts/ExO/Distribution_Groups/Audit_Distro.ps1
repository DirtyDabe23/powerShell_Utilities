#Distro 1 
$distroIdent = "esop-only-distro@uniqueParentCompany.com"
$csv = "C:\Users\$userName\OneDrive - uniqueParentCompany, Inc\Documents\_Project\_Distribution_Groups\ESOP\Email_Distribution_List_ESOP.csv"

$users = Import-CSV -Path $csv
$Distro = Get-DistributionGroup -identity $distroIdent
$DistroMembers = $Distro | Get-DistributionGroupMember -resultsize unlimited

$FailedAudit = @()

ForEach ($user in $users)
{
   If ($user.EmailAddress -notin $DistroMembers.primarySMTPAddress)
   {
   $FailedAudit+= [PSCustomObject]@{
        DistroName = $Distro.DisplayName
        'User Not In Distro' = $user.EmailAddress
        }
   } 

}

$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$fileName = $Date+"."+$Distro.DisplayName+".csv"

$FailedAudit | Export-CSV -path "C:\Users\$userName\OneDrive - uniqueParentCompany, Inc\Documents\_Project\_Distribution_Groups\ESOP\Audits\$($fileName)"

#Reset all variables to null
$distroIdent = $null
$csv = $null
$users = $null
$Distro = $null
$DistroMembers = $null
$FailedAudit = $null
$user = $null 



#Distro 2
$distroIdent = "esop-psip-distro@uniqueParentCompany.com"
$csv = "C:\Users\$userName\OneDrive - uniqueParentCompany, Inc\Documents\_Project\_Distribution_Groups\ESOP\Email_Distribution_List_ESOP_PSIP.csv"

$users = Import-CSV -Path $csv
$Distro = Get-DistributionGroup -identity $distroIdent
$DistroMembers = $Distro | Get-DistributionGroupMember -resultsize unlimited

$FailedAudit = @()

ForEach ($user in $users)
{
   If ($user.EmailAddress -notin $DistroMembers.primarySMTPAddress)
   {
   $FailedAudit+= [PSCustomObject]@{
        DistroName = $Distro.DisplayName
        'User Not In Distro' = $user.EmailAddress
        }
   } 

}

$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$fileName = $Date+"."+$Distro.DisplayName+".csv"

$FailedAudit | Export-CSV -path "C:\Users\$userName\OneDrive - uniqueParentCompany, Inc\Documents\_Project\_Distribution_Groups\ESOP\Audits\$($fileName)"

#Reset all variables to null
$distroIdent = $null
$csv = $null
$users = $null
$Distro = $null
$DistroMembers = $null
$FailedAudit = $null
$user = $null 



#Distro 3
$distroIdent = "psip-only-distro@uniqueParentCompany.com"
$csv = "C:\Users\$userName\OneDrive - uniqueParentCompany, Inc\Documents\_Project\_Distribution_Groups\ESOP\Email_Distribution_List_PSIP.csv"

$users = Import-CSV -Path $csv
$Distro = Get-DistributionGroup -identity $distroIdent
$DistroMembers = $Distro | Get-DistributionGroupMember -resultsize unlimited

$FailedAudit = @()

ForEach ($user in $users)
{
   If ($user.EmailAddress -notin $DistroMembers.primarySMTPAddress)
   {
   $FailedAudit+= [PSCustomObject]@{
        DistroName = $Distro.DisplayName
        'User Not In Distro' = $user.EmailAddress
        }
   } 

}

$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$fileName = $Date+"."+$Distro.DisplayName+".csv"

$FailedAudit | Export-CSV -path "C:\Users\$userName\OneDrive - uniqueParentCompany, Inc\Documents\_Project\_Distribution_Groups\ESOP\Audits\$($fileName)"



#Reset all variables to null
$distroIdent = $null
$csv = $null
$users = $null
$Distro = $null
$DistroMembers = $null
$FailedAudit = $null
$user = $null 

# SIG # Begin signature block#Script Signature# SIG # End signature block






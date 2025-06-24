#Distro 1 
$distroIdent = "esop-only-distro@Domain.extension1"
$csv = "C:\Users\David.drosdick\OneDrive - parentCompany, Inc\Documents\_Project\_Distribution_Groups\ESOP\Email_Distribution_List_ESOP.csv"

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

$FailedAudit | Export-CSV -path "C:\Users\David.drosdick\OneDrive - parentCompany, Inc\Documents\_Project\_Distribution_Groups\ESOP\Audits\$($fileName)"

#Reset all variables to null
$distroIdent = $null
$csv = $null
$users = $null
$Distro = $null
$DistroMembers = $null
$FailedAudit = $null
$user = $null 



#Distro 2
$distroIdent = "esop-psip-distro@Domain.extension1"
$csv = "C:\Users\David.drosdick\OneDrive - parentCompany, Inc\Documents\_Project\_Distribution_Groups\ESOP\Email_Distribution_List_ESOP_PSIP.csv"

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

$FailedAudit | Export-CSV -path "C:\Users\David.drosdick\OneDrive - parentCompany, Inc\Documents\_Project\_Distribution_Groups\ESOP\Audits\$($fileName)"

#Reset all variables to null
$distroIdent = $null
$csv = $null
$users = $null
$Distro = $null
$DistroMembers = $null
$FailedAudit = $null
$user = $null 



#Distro 3
$distroIdent = "psip-only-distro@Domain.extension1"
$csv = "C:\Users\David.drosdick\OneDrive - parentCompany, Inc\Documents\_Project\_Distribution_Groups\ESOP\Email_Distribution_List_PSIP.csv"

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

$FailedAudit | Export-CSV -path "C:\Users\David.drosdick\OneDrive - parentCompany, Inc\Documents\_Project\_Distribution_Groups\ESOP\Audits\$($fileName)"



#Reset all variables to null
$distroIdent = $null
$csv = $null
$users = $null
$Distro = $null
$DistroMembers = $null
$FailedAudit = $null
$user = $null 

SignatureBlock


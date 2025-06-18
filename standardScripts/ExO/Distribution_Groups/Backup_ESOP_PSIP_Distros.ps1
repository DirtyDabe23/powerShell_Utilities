#Specifies the Distro Groups to add to the array
$distro1 = "esop-only-distro@uniqueParentCompany.com"
$distro2 = "psip-only-distro@uniqueParentCompany.com"
$distro3 = "esop-psip-distro@uniqueParentCompany.com"


#Add the distros to the Array
$distroArr = @("$distro1","$distro2","$distro3")

ForEach ($distroIdent in $distroArr)
{
    $Distro = Get-DistributionGroup -identity $distroIdent
    $Date = Get-Date -Format yyyy.MM.dd.HH.mm
    $fileName = $Date+"."+$Distro.DisplayName+".csv"
    Get-DistributionGroupMember -Identity $distro -ResultSize Unlimited | Select DisplayName, PrimarySmtpAddress, EmailAddresses | Sort DisplayName | Export-CSv -Path "C:\Users\$userName\uniqueParentCompany, Inc\GIT IT Support - General\Reports\2024\ESOP-PSIP\Backup\$($fileName)"
}
# SIG # Begin signature block#Script Signature# SIG # End signature block






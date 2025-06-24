#Specifies the Distro Groups to add to the array
$distro1 = "esop-only-distro@Domain.extension1"
$distro2 = "psip-only-distro@Domain.extension1"
$distro3 = "esop-psip-distro@Domain.extension1"


#Add the distros to the Array
$distroArr = @("$distro1","$distro2","$distro3")

ForEach ($distroIdent in $distroArr)
{
    $Distro = Get-DistributionGroup -identity $distroIdent
    $Date = Get-Date -Format yyyy.MM.dd.HH.mm
    $fileName = $Date+"."+$Distro.DisplayName+".csv"
    Get-DistributionGroupMember -Identity $distro -ResultSize Unlimited | Select DisplayName, PrimarySmtpAddress, EmailAddresses | Sort DisplayName | Export-CSv -Path "C:\Users\david.drosdick\parentCompany, Inc\GIT IT Support - General\Reports\2024\ESOP-PSIP\Backup\$($fileName)"
}
SignatureBlock


#Specifies the CSVs to add to the array
$csv1 = "C:\Users\$userName\uniqueParentCompany, Inc\GIT IT Support - General\Reports\2024\ESOP-PSIP\Source\ESOP.csv"
$csv2 = "C:\Users\$userName\uniqueParentCompany, Inc\GIT IT Support - General\Reports\2024\ESOP-PSIP\Source\PSIP.csv"
$csv3 = "C:\Users\$userName\uniqueParentCompany, Inc\GIT IT Support - General\Reports\2024\ESOP-PSIP\Source\ESOP-PSIP.csv"

#creates the array and assigns the CSV to them
$csvArr = @("$csv1","$csv2","$csv3")

#Specifies the Distro Groups to add to the array
$distro1 = "esop-only-distro@uniqueParentCompany.com"
$distro2 = "psip-only-distro@uniqueParentCompany.com"
$distro3 = "esop-psip-distro@uniqueParentCompany.com"


#Add the distros to the Array
$distroArr = @("$distro1","$distro2","$distro3")

#counter for Array
$counter = 0 

While ($counter -lt 3)
{
$distroIdent = $distroArr[$counter]
$csv = $csvArr[$counter]

$users = Import-CSV -Path $csv
$Distro = Get-DistributionGroup -identity $distroIdent
$DistroMembers = $Distro | Get-DistributionGroupMember -resultsize unlimited

$FailedAudit = @()

ForEach ($user in $users)
{
   If ($distroMembers.EmailAddresses -like "*$($User.EmailAddress)*")
{
    Write-Output "Found $($User.EmailAddress) in $($Distro.DisplayName)"
}
Else
{
   $FailedAudit+= [PSCustomObject]@{
      DistroName = $Distro.DisplayName
      'User Not In Distro' = $user.EmailAddress
      }
}

}
$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$fileName = $Date+"."+$Distro.DisplayName+".csv"

$FailedAudit | Export-CSV -path "C:\Users\$userName\uniqueParentCompany, Inc\GIT IT Support - General\Reports\2024\ESOP-PSIP\Post\$($fileName)"

#Reset all variables to null
$distroIdent = $null
$csv = $null
$users = $null
$Distro = $null
$DistroMembers = $null
$FailedAudit = $null

#increment counter
$counter++


}

# SIG # Begin signature block#Script Signature# SIG # End signature block






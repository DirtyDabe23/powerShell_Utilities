#connect to Exchange Online
$exoCertThumb = "f5fae1b6ead4efdf33c5a79175561763cac5fb16"
$exoAppID = "1f97c81e-f222-4046-967a-5051db6f1ec1"
$exoORG = "uniqueParentCompanyinc.onmicrosoft.com"
		
Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG

$subLists = Get-DistributionGroupMember -Identity "North American Employees Distro"
$fullTracker = @()

ForEach ($subList in $subLists)
{
    $subListMembers = Get-DistributionGroupMember -Identity $subList.Name
    
    ForEach ($member in $subListMembers)
    {
        $row = [PSCustomObject]@{
            'DistroGroup Name'        = $subList.Name
            'DistroGroup Recipient Type' = $subList.RecipientType
            'Username'               = $member.Name
            'User Recipient Type'     = $member.RecipientType
        }
        $fullTracker += $row
    }
}

# Export the results to a CSV file
$fullTracker | Export-Csv -Path "C:\Users\$userName\Documents\2023_Scripts\ExchangeOnline\Distribution_Groups\NAE_Export.csv" -NoTypeInformation

# SIG # Begin signature block#Script Signature# SIG # End signature block






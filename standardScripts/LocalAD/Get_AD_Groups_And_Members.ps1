$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$Share = Read-Host -Prompt "Enter the Path for the export. Example: \\uniqueParentCompanyUSERS\Departments\Public\Tech-Items\"
$Path = "$Share"+"$date"+"_ADGroups.csv"

Get-ADGroup -Filter * | Export-CSV -path $Path

$Groups = Get-ADGroup -Filter *
Set-Location $Share
ForEach ($group in $Groups)
{
    $Date = Get-Date -Format yyyy.MM.dd.HH.mm
    $fileName = $Date+"."+$group.name+".csv"
    Get-ADGroupMember -Identity $group.name | Export-CSV -Path .\$fileName
}
# SIG # Begin signature block#Script Signature# SIG # End signature block





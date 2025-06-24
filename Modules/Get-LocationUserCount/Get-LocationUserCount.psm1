function Get-LocationUserCount {
    <#
    .SYNOPSIS
    Gets the number of users in each location.
    .DESCRIPTION
    Gets the number of users in each location.
    .COMPONENT
    EntraID, Jira
    .PARAMETER jiraUser
    The username of the account that is being used to connect to Jira via the API. It
    defaults to the current user's username and domain.
    .PARAMETER jiraKey
    The Jira API key for authentication. This should be a valid API token.
    .PARAMETER locationType
    Specify the type of location to filter by. All will return a split list of Shop and Office Users Office will return only Office Users.
    Combined will return a combined list of Office and Shop Users.
    .EXAMPLE
    Get-LocationUserCount
    .LINK
    https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview?view=graph-powershell-1.0
    https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#permissions
    .OUTPUTS
    A list of locations with the number of users in each location.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0,HelpMessage = "Enter the username of the account that is being used to connect to Jira via the API.`nIt will default to your UserName and UserDNSDomain")]
        [string] $jiraUser =  ($env:UserName,'@' , $env:UserDNSDOmain.tolower() -join ""),
        [Parameter(Position = 1, HelpMessage = "Enter your API Key for Jira", Mandatory = $true)]
        [string] $jiraKey,
        [Parameter(Mandatory = $false,helpMessage = "Specify the type of location to filter by. All will return a split list of Shop and Office Users.`n
        Office will return only Office Users.`n
        Shop will return only Shop Users.`n
        Combined will return a combined list of Office and Shop Users.")]
        [ValidateSet("All", "Office", "Shop", "Combined","Needs Specified")]
        [string]$locationType = "Combined",
        [parameter(Mandatory = $false,HelpMessage = "Specify the name of the custom field to use for locations. Defaults to 'parentCompany Location'.")]
        [string]$customFieldName = "parentCompany Location",
        [Parameter(Mandatory = $false,HelpMessage = "Specify this if you would like to export the results to a CSV file. Defaults to `$false.")]
        [switch]$exportToCSV = $false,
        [Parameter(Mandatory = $false,HelpMessage = "Specify the path to export the results to. Defaults to C:\Temp\yyyy-MM-dd-locationUserCount.csv")]
        [string]$exportPath = "C:\Temp\",
        [Parameter(Mandatory = $false,HelpMessage = "Specify the date format for the export file name. Defaults to 'yyyy-MM-dd'.")]
        [string]$dateFormat = 'yyyy-MM-dd'

    )
    $today = Get-Date -Format $dateFormat
    $locations = @()
    $parentCompanyLocations = Get-CustomFieldValues -customFieldName $customFieldName -jiraUser $jiraUser -jiraKey $jiraKey
    if ($null -eq $parentCompanyLocations) {
        Throw "No parentCompany Locations found. Please ensure the custom field exists."
    }
    $allUsers = Get-MgBetaUser -All -ConsistencyLevel eventual | Select-Object -Property *
    $employees = $allUsers | Where-Object {($_.CompanyName -ne 'Not Affiliated') -and ($_.UserType -eq 'Member') -and ($_.AccountEnabled -eq $true)}
    ForEAch ($location in $parentCompanyLocations.value){
        $locations += $location
    }
    $employeeCounts = @()
    ForEAch ($location in $locations){
        If($locationType -eq 'All') {
            $officeOrShop = @("Office","Shop",$null)
            forEach ($type in $officeOrShop) {
                $employeeCount = ($employees | Where-Object {($_.OnPremisesExtensionAttributes.ExtensionAttribute1 -eq $type) -and ($_.OfficeLocation -eq $location)}).Count
                if ($null -eq $type){
                    $type = "Needs Specififed"
                }
                $employeeCounts += [PSCustomObject]@{
                    locationName = $location
                    numberOfEmployees = $employeeCount
                    locationType = $type
                }
            }
        }
        elseif($locationType -eq 'Combined'){
                $employeeCount = ($employees | Where-Object {($_.OfficeLocation -eq $location)}).Count
                $employeeCounts += [PSCustomObject]@{
                    locationName = $location
                    numberOfEmployees = $employeeCount
                    locationType = $locationType
                }
        }
        elseif($locationType -eq 'Needs Specified'){
            $employeeCount = ($employees | Where-Object {($null -eq $_.OnPremisesExtensionAttributes.ExtensionAttribute1) -and ($_.OfficeLocation -eq $location)}).Count
            $employeeCounts += [PSCustomObject]@{
                    locationName = $location
                    numberOfEmployees = $employeeCount
                    locationType = "Needs Specififed"
                }
        }
        else{
            $employeeCount = ($employees | Where-Object {($_.OnPremisesExtensionAttributes.ExtensionAttribute1 -eq $locationType) -and ($_.OfficeLocation -eq $location)}).Count
            $employeeCounts += [PSCustomObject]@{
                    locationName = $location
                    numberOfEmployees = $employeeCount
                    locationType = $locationType
                }
        }
    }
    $employeeCounts = $employeeCOunts | Sort-Object -Property numberOfEmployees -Descending   
    if ($exportToCSV) {
        $exportFileName = "$today-locationUserCount.csv"
        $exportFullPath = Join-Path -Path $exportPath -ChildPath $exportFileName
        $employeeCounts | Export-Csv -Path $exportFullPath -NoTypeInformation
        Write-Host "Exported results to $exportFullPath"
    }
    else {
        Write-Output "Results not exported. Use -exportToCSV to export the results."
    }
    return $employeeCounts
}
SignatureBlock


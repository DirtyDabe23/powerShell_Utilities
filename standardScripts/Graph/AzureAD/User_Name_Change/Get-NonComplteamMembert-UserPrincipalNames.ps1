#File Creation Objects
$process = "Non-ComplteamMembert UserName Audit"
$shareLoc = "\\uniqueParentCompanyusers\departments\Public\Tech-Items\scriptLogs\"
$reportCSV = "$($process).csv"
$dateTime = Get-Date -Format yyyy.MM.dd.HH.mm
$reportExportPath = $shareLoc+$dateTime+"."+$reportCSV
$Users = Get-MGBetaUser -All -ConsistencyLevel eventual | Where-Object {($_.UserType -eq "member") -and ($_.DisplayName -ne "On-Premises Directory Synchronization Service Account") -and ($_.AccountEnabled -eq $true) -and ($_.CompanyName -NE 'Not Affiliated') -and ($_.ExtensionAttribute14 -ne 'ComplteamMembert')} 
$allusersToFix  = @()

ForEach ($user in $users)
{
    $userUPNSuffix = $user.UserPrincipalName.split("@")[1]
    $complteamMembertUPN = $user.GivenName + "." + $user.Surname +"@"+$userUPNSuffix

    if ($complteamMembertUPN -ne $user.UserPrincipalName)
    {
        Write-Output "$($user.DisplayName) requires a name modification"
        $allusersToFix += [PSCustomObject]@{
            user = $user.displayName
            department = $user.department
            officeLocation = $user.OfficeLocation
            company = $user.CompanyName
            currentUPN = $user.UserPrincipalName
            newUPN = $complteamMembertUPN
            synching = $user.OnPremisesSyncEnabled
            onPremSAM = $user.OnPremisesSamAccountName
        }
    }

    
}

$allusersToFix | Export-Csv -Path $reportExportPath -Force
[pscustomobject]$nameConflict = @()
[pscustomobject]$noConflict = @()
ForEach($usertoFix in $allUsersToFix){
    If(($allusersToFix | Where-Object {($_.NewUPN -eq $usertofix.newUPN)}).count -gt 1){
        $nameConflict +=$usertoFix
    }
    else{
        $noConflict += $usertoFix
        
    }
}
$nameConflicts= "$($process)_nameConflicts.csv"
$conflictsExportPath = $shareLoc+$dateTime+"."+$nameConflicts
$noConflicts= "$($process)_noConflict.csv"
$noConflictsExportPath = $shareLoc+$dateTime+"."+$noConflicts

$nameConflict | Export-CSV -Path $conflictsExportPath
$noConflict | Export-CSV -path $noConflictsExportPath



# SIG # Begin signature block#Script Signature# SIG # End signature block






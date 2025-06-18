#File Creation Objects
$process = "Non-ComplteamMembert UserName Audit"
$shareLoc = "\\uniqueParentCompanyusers\departments\Public\Tech-Items\scriptLogs\"
$userImport = "\\uniqueParentCompanyusers\departments\Public\Tech-Items\Script Configs\uniqueParentCompanyHQ_Shop.csv"
Write-Output "The following file is being used as the source of users $userImport"
$reportCSV = "$($process).csv"
$dateTime = Get-Date -Format yyyy.MM.dd.HH.mm
$reportExportPath = $shareLoc+$dateTime+"."+$reportCSV
$Users = Get-MGBetaUser -All -ConsistencyLevel eventual | Where-Object {($_.UserType -eq "member") -and ($_.DisplayName -ne "On-Premises Directory Synchronization Service Account") -and ($_.AccountEnabled -eq $true) -and ($_.CompanyName -NE 'Not Affiliated')} 
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

$process = "Bulk Username Change"
#Sets the PowerShell Window Title
$host.ui.RawUI.WindowTitle = $process

#Clears the Error Log
$error.clear()


#This WMI Query gets a ton of rich information about the endpoint
#File Creation Objects
$usersImported = Import-Csv -path $userImport
$logFileName = "$($process).txt"
$dateTime = Get-Date -Format yyyy.MM.dd.HH.mm
$exportPath = $shareLoc+$dateTime+"."+$logFileName
Start-Transcript -Path $exportPath
ForEach ($user in $usersImported){if($user.newUPN -in $noConflict.newUPN){"Renaming $($user.currentUPN) to $($user.NewUPN)"
Rename-uniqueParentCompanyUser -currentUserName $user.currentUPN -newUPN $user.newUPN -auto
}
}

Stop-Transcript


# SIG # Begin signature block#Script Signature# SIG # End signature block







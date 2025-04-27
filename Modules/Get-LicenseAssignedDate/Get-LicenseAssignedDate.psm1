function Get-LicenseAssignmentDate{
    <#
    .SYNOPSIS
    #This function will return all licenses and the first date that they were assigned to a user.
    
    .DESCRIPTION
    This function connects to Microsoft Graph and retrieves all users. 
    It will then retreive all of the SKUs that are enabled in the tenant, where there is an active assignment.
    It will then go through all of the users and determine when the license was first assigned to them.
    
    
    .EXAMPLE
    Get-LicenseAssignmentDate
    
    .NOTES
    This was specifically created for a full tenant audit of all users and their assigned licenses. 
    For individual users, you would use the following, reviewing the 'AssignedDateTime' Property
    $userID = "givenName.surName@domain.extension"
    Get-MgbetaUser -userid $userID  | select AssignedPlans -ExpandProperty AssignedPlans 
    #>
    $licenseAssignmentData = @()
    $allUsers = Get-MGBetaUser -all -consistencylevel:eventual
    $totalAssignedLicenses = Get-MGSubscribedSKU | Where-Object {($_.AppliesTo -eq 'User') -and ($_.ConsumedUnits -gt 0)} | Sort-Object -Property ConsumedUnits -Descending
    ForEach ($individualLicense in $totalAssignedLicenses){
        $licensedUsers = $allUSers | Where-Object {($_.AssignedLicenses.SkuId -contains $individualLicense.SkuId)}
        
        ForEach ($licensedUser in $licensedUsers){
            $licensedAssignedAt = $licensedUser.AssignedPlans | Where-Object {($_.ServicePlanID -in $individualLicense.ServicePlans.ServicePlanID)} | Select-Object AssignedDateTime -Unique | Sort-Object -Top 1
            $licenseAssignmentData +=[PSCustomObject]@{
                userName                = $licensedUser.DisplayName
                userUPN                 = $licensedUser.UserPrincipalName
                userID                  = $licenseduser.Id
                userTitle               = $licensedUser.JobTitle
                department              = $licensedUser.Department
                officeLocation          = $licensedUser.OfficeLocation
                company                 = $licensedUser.CompanyName
                licenseName             = $individualLicense.SkuPartNumber
                licenseAssignedAt       = $licensedAssignedAt.AssignedDateTime
            }
        }
    }
    return $licenseAssignmentData

}
# SIG # Begin signature block#Script Signature# SIG # End signature block




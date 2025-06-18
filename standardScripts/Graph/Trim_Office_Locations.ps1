Clear-Host

Connect-MGGraph -NoWelcome


$process = "uniqueParentCompany Office Location Trims"
$allStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] [$process] Starting"

 $errorLog = @()
 $usersModified = @()


$users = Get-MGBetaUser -all -consistencylevel:eventual | Where-Object {($_.UserType -eq "member") -and ($_.AccountEnabled -eq $true) -and ($_.CompanyName -ne "Not Affiliated")}

ForEach ($user in $users)
{
    $officeLocationLength = $user.officelocation.length

    If ($user.OfficeLocation -eq $null -OR $user.officeLocation -eq '' -OR $user.OfficeLocation -eq ' ')
    {
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [$process] | [User: $($user.displayName)] | Null Office Name"
    }
    ElseIf ($user.officelocation.Substring($officeLocationLEngth-1) -eq " ")
    {
        $fixedLocation = $user.officelocation.trim()
        try 
        {
            
            Update-MGBetaUser -userID $user.ID -OfficeLocation $fixedLocation -erroraction Stop
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [$process] | [User: $($user.displayName)] | Trim Successful"
            $usersModified += [PSCustomObject]@{
                modifiedUser = $user.DisplayName
                oldOfficeLocation = $user.OfficeLocation
                newOfficeLocation = $fixedLocation   
            }
        }
        catch 
        {
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [$process] | [User: $($user.displayName)] | Trim Failed"
            $errorLog += [PSCustomObject]@{
                failedTarget        = $user.DisplayName
                ReasonFailed        = $error[0] #gets the most recent error
            }   
        }
        
    }
    else 
    {
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [$process] | [User: $($user.displayName)] | Trim Not Required"
    }
    
}

#For Full Script End:
$currTime = Get-Date -format "HH:mm"
$allEndTime = Get-Date 
$allNetTime = $allEndTime - $allStartTime
Write-Output "[$($currTime)] | [$process] | Time taken for [$process] completed in: $($allNetTime.hours) hours, $($allNetTime.minutes) minutes, $($allNetTime.seconds) seconds"
# SIG # Begin signature block#Script Signature# SIG # End signature block





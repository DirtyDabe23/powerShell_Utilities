Clear-Host
$complteamMembertGroups = @()
$noncomplteamMembertGroups = @()
#Error Logging
$errorLogFull = @()
$process = "Dynamic Distro Check"
$dynamicDistros = Get-DynamicDistributionGroup -ResultSize unlimited
$totalCount = $dynamicDistros.count
$counter = 1
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [$process] [$counter / $totalCount] Starting"
ForEach ($dynamicDistro in $dynamicDistros)
{
    try
    {
        Write-Output "[$($currTime)] | [$process] [$counter / $totalCount] Evaluating: $($dynamicDistro.Name)"


        $baseFilter = $dynamicDistro.RecipientFilter
        
        if ($baseFilter -like "*-and (-not(Company -eq 'Not Affiliated'))*")
        {   
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [$process] [$counter / $totalCount] Status: Filter Contains Exclusion"
            $complteamMembertGroups +=[PSCustomObject]@{
                Name = $dynamicDistro.Name
                originalFilter = $baseFilter
            }
        }
        Else
        {
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [$process] [$counter / $totalCount] Status: Filter Needs Exclusion"
            $newFilter = $dynamicDistro.RecipientFilter + " -and (-not(Company -eq 'Not Affiliated'))"
            $originalMembers = Get-DynamicDistributionGroupMember -Identity $dynamicDistro -ResultSize Unlimited
            Set-DynamicDistributionGroup -identity $dynamicDistro.Identity -RecipientFilter $newFilter -forcemembershiprefresh -erroraction Stop
            do {
                $updatedDistro = Get-DynamicDistributionGroup -Identity $dynamicDistro
                $currTime = Get-Date -format "HH:mm"
                Write-Output "[$($currTime)] | [$process] [$counter / $totalCount] Status: Waiting for Membership Refresh"
                Start-Sleep -Seconds 10
                
            } while ($updatedDistro.CalculatedMembershipUpdateTime -eq $dynamicDistro.CalculatedMembershipUpdateTime)

            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [$process] [$counter / $totalCount] Status: Pulling Members Refresh"
            $newMembers = Get-DynamicDistributionGroupMember -Identity $dynamicDistro -ResultSize Unlimited -erroraction Stop
            $noncomplteamMembertGroups +=[PSCustomObject]@{
                Name = $dynamicDistro.Name
                originalFilter = $baseFilter
                originalMembers = $originalMembers
                originalMembersCount = $originalMembers.count
                newFilter      = $newFilter
                newMembers = $newMembers
                newMembersCount = $newMembers.count

            }
        }
    }
    catch{
        $currTime = Get-Date -format "HH:mm"
            $errorLogFull += [PSCustomObject]@{
                groupFailed                   = $dynamicDistro.Name
                timeToFail                      = $currTime
                reasonFailed                    = $error[0] #gets the most recent error


            }

    }
    $counter++
}
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [$process] [$counter / $totalCount] Status: Completed."
# SIG # Begin signature block#Script Signature# SIG # End signature block






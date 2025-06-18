Clear-Host
Write-Output "The following programs are able to be removed via this process`r`n"
Get-CimInstance -Class Win32_Product | sort-object -property "Name" | Format-Table -AutoSize
#Pulls the program name from the config file
$ProgName = "GFI LanGuard 12 Agent"
#Logging
Write-Output "`r`n`r`n`r`nProgram to Remove: $ProgName"
$uninstallStartTime = Get-Date 
Write-Output "Verifying Instance at $uninstallStartTime"

#Verifies input is clean and finds the exact program name. 
If(Get-CimInstance -Class Win32_Product -Filter "Name = '$ProgName'")
{
    Write-Output "CIM Instance Mapped Correctly! `r`nAttempting Removal.`r`nStarting at $uninstallStartTime"
    #Heavy lifting
    Get-CimInstance -Class Win32_Product -Filter "Name = '$ProgName'" | Invoke-CimMethod -Name Uninstall

    #Verifies the uninstall was successful
    If(!(Get-CimInstance -Class Win32_Product -Filter "Name = '$ProgName'"))
    {
    $uninstallEndTime = Get-Date
    $uninstallNetTime = $uninstallEndTime - $uninstallStartTime
    $uninstallProcess = "SolidEdge Uninstall"
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | Time taken for [$uninstallProcess] to complete: $($uninstallNetTime.hours) hours, $($uninstallNetTime.minutes) minutes, $($uninstallNetTime.seconds) seconds"
    #exit
    }
    #Messages to display if the process fails for troubleshooting purposes / steps
    Else
    {
    Write-Output "Time taken to FAIL: $((Get-Date).Subtract($start_time).Seconds) second(s)"
    Write-Output "Check AV to make sure it's not being blocked `r`n"
    Write-Output "If the above fails, something is wrong. `r`n"
    #exit
    }
}
#General error message if user input is wrong
Else
{
Write-Output "No CIM Instance found for removal of this program. Check your spelling or the program name."
Write-Output "If you have already confirmed the spelling, this removal process is not compatible"
Get-CimInstance -Class Win32_Product | Format-Table -AutoSize
#exit
}

# SIG # Begin signature block#Script Signature# SIG # End signature block




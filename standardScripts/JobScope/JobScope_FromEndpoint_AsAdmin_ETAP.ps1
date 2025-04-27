#Lists all programs that can be uninstalls via this method
Write-host "The following programs are able to be removed via this process`r`n"
Get-CimInstance -Class Win32_Product | Format-Table -AutoSize
#Pulls the program name from the config file
$ProgName = "Jobscope"
#Logging
Write-Host "`r`n`r`n`r`nProgram to Remove: $ProgName"
$start_time = Get-Date
Write-Host "Verifying Instance at $start_time"

#Verifies input is clean and finds the exact program name. 
If(Get-CimInstance -Class Win32_Product -Filter "Name = '$ProgName'")
{
    Write-Host "CIM Instance Mapped Correctly! `r`nAttempting Removal.`r`nStarting at $start_time"
    #Heavy lifting
    Get-CimInstance -Class Win32_Product -Filter "Name = '$ProgName'" | Invoke-CimMethod -Name Uninstall

    #Verifies the uninstall was successful
    If(!(Get-CimInstance -Class Win32_Product -Filter "Name = '$ProgName'"))
    {
    Write-Output "Time taken to Uninstall: $((Get-Date).Subtract($start_time).TotalSeconds) second(s)"
    Write-Output "Removal Successful!"
    #exit
    }
    #Messages to display if the process fails for troubleshooting purposes / steps
    Else
    {
    Write-Output "Time taken to FAIL: $((Get-Date).Subtract($start_time).TotalSeconds) second(s)"
    Write-Output "Check AV to make sure it's not being blocked `r`n"
    Write-Output "If the above fails, something is wrong. `r`n"
    #exit
    }
}
#General error message if user input is wrong
Else
{
Write-Host "No CIM Instance found for removal of this program. Check your spelling or the program name."
Write-Host "If you have already confirmed the spelling, this removal process is not compatible"
Get-CimInstance -Class Win32_Product | Format-Table -AutoSize
#exit
}

Copy-Item -Path "\\svr_r730\General Share\IT\JobScope\24.4\" -Destination "C:\Temp\JobScope" -Recurse
Unblock-File -Path "C:\Temp\JobScope\Official Jobscope Enterprise (24.04.0)\Installs\Client\Jobscope.msi" 
Start-Process -FilePath "C:\Temp\JobScope\Official Jobscope Enterprise (24.04.0)\Installs\Client\Jobscope.msi" -argumentlist "/qn" -Wait


Get-CimInstance -Class Win32_Product -Filter "Name = '$ProgName'"
# SIG # Begin signature block#Script Signature# SIG # End signature block




#Lists all programs that can be uninstalls via this method
Write-Output "The following programs are able to be removed via this process`r`n"
Get-CimInstance -Class Win32_Product | Format-Table -AutoSize
#Pulls the program name from the config file
$ProgName = "Siemens Solid Edge 2022"
#Logging
Write-Output "`r`n`r`n`r`nProgram to Remove: $ProgName"
$start_time = Get-Date
Write-Output "Verifying Instance at $start_time"

#Verifies input is clean and finds the exact program name. 
If(Get-CimInstance -Class Win32_Product -Filter "Name = '$ProgName'")
{
    Write-Output "CIM Instance Mapped Correctly! `r`nAttempting Removal.`r`nStarting at $start_time"
    #Heavy lifting
    Get-CimInstance -Class Win32_Product -Filter "Name = '$ProgName'" | Invoke-CimMethod -Name Uninstall

    #Verifies the uninstall was successful
    If(!(Get-CimInstance -Class Win32_Product -Filter "Name = '$ProgName'"))
    {
    Write-Output "Time taken to Uninstall: $((Get-Date).Subtract($start_time).Seconds) second(s)"
    Write-Output "Removal Successful!"
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

Start-Process -FilePath "\\uniqueParentCompanyusers\departments\IR-Engineering\SE 2024 Install\Solid_Edge_2024_2310.exe" -ArgumentList '/s /v" /qn"' -Wait
Start-Process -FilePath "\\uniqueParentCompanyusers\departments\IR-Engineering\SE 2024 Install\Solid_Edge_MSI_Update0005.exe" -ArgumentList '/s /v" /qn"' -Wait
[System.Environment]::SetEnvironmentVariable('SE_License_Server', '29000@Hertz-TFS','Machine')


# SIG # Begin signature block#Script Signature# SIG # End signature block





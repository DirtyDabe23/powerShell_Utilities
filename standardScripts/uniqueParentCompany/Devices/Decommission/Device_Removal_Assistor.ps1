Clear-Host
If ($null -eq $cred)
{
    $cred = Get-Credential
}

$computerName = Read-Host "Enter the ComputerName here"
$serverName = Read-Host "Enter the Domain Controller who hosts the Active Directory the Computer is on"


Try{
Invoke-Command -ComputerName $serverName -ScriptBlock {param ($computerName) Get-ADComputer $computerName | Remove-ADComputer -confirm:$false} -ArgumentList $computerName -Credential $cred -ErrorAction Stop
}

Catch{
    Write-Output "Error on Attempting to Remove the AD Computer from the domain"
    Try{
        Write-Output "Re-attempting removal"
        Invoke-Command -ComputerName $serverName -ScriptBlock {param ($computerName) Get-ADComputer $computerName | Remove-ADObject -confirm:$false -recursive} -ArgumentList $computerName -Credential $cred -ErrorAction Stop

    }
    Catch{
        Write-OUtput "Unable to remove $computerName. Please do this manually"
    }
}


Connect-MgGraph -NoWelcome
$mgDevices = Get-MGDevice -search "displayName:$computerName" -ConsistencyLevel eventual -erroraction silentlycontinue

If ($mgDevices.count -ge 1)
{
    Write-Output "Device Found"

ForEach ($mgDevice in $mgDevices)
{
    Remove-MGDevice -deviceID $mgDevice.id -confirm:$false
}
}

$inTuneDevices = Get-MGDeviceManagementManagedDevice -filter "deviceName eq `'$computerName'"

If ($inTuneDevices.count -ge 1)
{
    Write-Output "Device Found"

ForEach ($inTuneDevice in $inTuneDevices)
{
    Remove-MgDeviceManagementManagedDevice -ManagedDeviceID $inTuneDevice.id -confirm:$false
}
}

# SIG # Begin signature block#Script Signature# SIG # End signature block




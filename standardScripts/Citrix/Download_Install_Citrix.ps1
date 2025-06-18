$url = "https://downloads.citrix.com/22695/CitrixWorkspaceApp.exe?__gda__=exp=1718810737~acl=/*~hmac=c5be228506de4ed91cadcca803fee732cfa53f8cb32d5c15e12fee8bf127bbf8"
$computerName = hostname
#$Path is the containing folder for the process.
$Path = "C:\GIT_Scripts"

$progs = Get-CimInstance -Class Win32_Product


#$output = Location and Name where File should Be Saved
$output = "C:\GIT_Scripts\Citrix243197.exe"
$start_time = Get-Date

if (!(Test-Path $Path))
{
New-Item -itemType Directory -Path C:\ -Name GIT_Scripts
}
else
{
Write-Output "Folder already exists"
}


#Downloads the file specified
Write-Output "Time Of Process Start: $start_time"
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
Invoke-WebRequest -Uri $url -OutFile $output

$Start_Time = Get-Date 

$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | Upgrading: $computerName)"

Unblock-File -Path $output

If($progs -like "*Citrix*")
{
    Start-Process -FilePath $output -ArgumentList '/uninstall /silent' -Wait
}
Start-Process -FilePath $output -argumentList '/silent /noreboot /autoUpdateCheck=Auto'  -wait

$procName = "Windows10UpgraderApp"
$procRunning = $true
while ($procRunning -eq $true)
{
    Try{
        Get-Process -name $procName -ErrorAction Stop
        Start-Sleep -seconds 10
    } 
    Catch 
    {
        Write-Output "Process not detected"
        $procRunning = $false
    }

}

$endTime = Get-Date
$netTime = $endTime - $start_Time 

Write-Output "[$($currTime)] | Time taken for [Citrix Update] to complete: $($netTime.hours) hours, $($netTime.minutes) minutes, $($netTime.seconds) seconds"
# SIG # Begin signature block#Script Signature# SIG # End signature block




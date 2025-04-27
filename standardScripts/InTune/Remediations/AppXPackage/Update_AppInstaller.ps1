$url = "https://aka.ms/getwinget"

#$Path is the containing folder for the process.
$Path = "C:\GIT_Scripts"

#$output = Location and Name where File should Be Saved
$output = "C:\GIT_Scripts\AppXInstaller.MSIXBundle"
$start_time = Get-Date

if (!(Test-Path $Path))
{
New-Item -itemType Directory -Path C:\ -Name GIT_Scripts
}
else
{
write-host "Folder already exists"
}


#Downloads the file specified
Write-Output "Time Of Process Start: $start_time"
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
Invoke-WebRequest -Uri $url -OutFile $output


Add-AppxPackage -path $output -InstallAllResources
# SIG # Begin signature block#Script Signature# SIG # End signature block





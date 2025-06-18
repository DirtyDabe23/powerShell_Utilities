#This script downloads and runs a file process determined by the url variable.
#Variable Declaration
#$URL= Download Link
$url = "https://aka.ms/AzureConnectedMachineAgent"


#$Path is the containing folder for the process.
$Path = "C:\Temp"
$FileName = "AzureConnectedMachineAgent.msi"
#$output = Location and Name where File should Be Saved
$output = $Path+'\'+$FileName
$start_time = Get-Date

if (!(Test-Path $Path))
{
New-Item -itemType Directory -Path C:\ -Name Temp
}
else
{
write-host "Folder already exists"
}


#Downloads the file specified
Write-Output "Time Of Download Start: $start_time"
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
Invoke-WebRequest -Uri $url -OutFile $output
Write-Output "Time taken for Download: $((Get-Date).Subtract($start_time).TotalSeconds) second(s)"


#Runs the utility from Download
$start_time=Get-Date
Set-Location -Path "C:\Windows\System32"
Write-Output "Time Of Install Start: $start_time"
start-process $output -ArgumentList "/qn" -Wait
Write-Output "Time taken to Install: $((Get-Date).Subtract($start_time).TotalSeconds) second(s)"



$start_time=Get-Date
Write-Output "Time Of Configuraton Start: $start_time"
Start-Process -FilePath "C:\Program Files\AzureConnectedMachineAgent\azcmagent.exe" -ArgumentList  "connect" , "--resource-group 'AzureARC_uniqueParentCompanyEAST'" , "--tenant-id graphTenantID" , '--location EastUS' , "--subscription-id azSubsription" -NoNewWindow
Write-Output "Time taken to Configure: $((Get-Date).Subtract($start_time).TotalSeconds) second(s)"



# SIG # Begin signature block#Script Signature# SIG # End signature block








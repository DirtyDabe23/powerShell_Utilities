$officeLoc = "unique-Company-Name-2"
$companyName = "unique-Company-Name-2"
$country = "US"
$phoneNumber = "+17173477500"

$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$locName = (Get-ADDomain).name

$fileName = $Date+"."+$locName+".csv"

Get-ADUser -Filter * -Properties *  | Export-CSV -Path C:\Temp\$fileName

$Users = Get-ADUser -Filter * -Properties * 

ForEach ($user in $users)
{
    if($user.Company -eq $null)
    {
        Write-Host "Modifiying $($user.displayName)'s company name, which is currently $($user.company)"
	    Set-ADUser $user.SID -company $companyName
    }
    if ($user.Office -eq $null)
    {
        Write-Host "Modifiying $($user.displayName)'s office name, which is currently $($user.office)"
	    Set-ADUser $user.SID -office $officeLoc
    }

    if ($user.country -eq $null)
    {
    Write-Host "Modifiying $($user.displayName)'s country, which is currently $($user.country)"
	Set-ADUser $user.SID -country $country
    }

    if ($user.OfficePhone -eq $null)
    {
    Write-Host "Modifiying $($user.displayName)'s phone number, which is currently $($user.officephone)"
	Set-ADUser $user.SID -OfficePhone $phoneNumber
    }
 
}
Write-Host "Waiting one minute to allow for file name change"
Start-Sleep -Seconds 60
$Date = Get-Date -Format yyyy.MM.dd.HH.mm

$fileName = $Date+"."+$locName+".csv"

Get-ADUser -Filter * -Properties *  | Export-CSV -Path C:\Temp\$fileName
# SIG # Begin signature block#Script Signature# SIG # End signature block





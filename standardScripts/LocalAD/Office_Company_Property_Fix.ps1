$officeLoc = "unique-Office-Location-2"
$companyName = "uniqueParentCompany, Inc"
$phoneNumber = "2179233431"
$country = "Enter Country"


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
    
    if ($user.OfficePhone -eq $null)
    {
        Write-Host "Modifiying $($user.displayName)'s office phone number, which is currently $($user.OfficePhone)"
	    Set-ADUser $user.SID -OfficePhone $phoneNumber
    }

    if ($user.Country -eq $null)
    {
        Write-Host "Modifiying $($user.displayName)'s country, which is currently $($user.country)"
	    Set-ADUser $user.SID -Country $country
    }


    #Correcting improper locations after the first pass and we check the CSV for results 
    #if ($user.Office -eq "unique-Office-Location-27")
    #{
        #Write-Host "Modifiying $($user.displayName)'s office name, which is currently $($user.office)"
	    #Set-ADUser $user.SID -office $officeLoc
    #}
    #if ($user.Office -eq "Location3")
    #{
        #Write-Host "Modifiying $($user.displayName)'s office name, which is currently $($user.office)"
	    #Set-ADUser $user.SID -office $officeLoc
    #}
}
Write-Host "Waiting one minute to allow for file name change"
Start-Sleep -Seconds 60
$Date = Get-Date -Format yyyy.MM.dd.HH.mm

$fileName = $Date+"."+$locName+".csv"

Get-ADUser -Filter * -Properties *  | Export-CSV -Path C:\Temp\$fileName
# SIG # Begin signature block#Script Signature# SIG # End signature block








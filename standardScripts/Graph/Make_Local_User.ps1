Connect-MgGraph -Identity
$newUserPAth = $null
$condition = $false

do {
    $creatingUser = Read-Host "Enter the UPN of the user to create a local account for"
    $mgUSer = GEt-MGBetaUser -userid $creatingUser -erroraction SilentlyContinue
    If ($mgUser)
    {
        Write-Output "$($mgUser.DisplayName) detected, pulling down to make on Local AD"
        $condition = $true
    }
} while (
    !($condition) 
)



$managerID = Get-MGUserManager -userid $mgUser.id
$manager = Get-MGBetaUser -userid $managerId.ID
$path = $manager.OnPremisesDistinguishedName
$splitPath = $path.Split(',')
$i = 1
While ($i -lt $splitPath.count)
{
    Write-output "$i in the split"
    $newUserPath += $splitPath[$i]+","
    $i++
}
$newUserPath = $NewUserPath.trim(',')

$date = get-date $date


$DoW = $date.DayOfWeek.ToString()
$Month = (Get-date $date -format "MM").ToString()
$Day = (Get-date $date -format "dd").ToString()
$pw = $DoW+$Month+$Day+"!"
$password = ConvertTo-SecureString -string "$pw" -AsPlainText -Force




$displayName = $mgUser.DisplayName 
$usageLoc = $mgUser.UsageLocation 
$emailAddr = $mgUser.UserPrincipalName 
$businessPhone = $mgUser.BusinessPhones[0] 
$company = $mgUser.CompanyName
$jobtitle = $mgUser.JobTitle 
$DepartmentString = $mgUser.Department 
$firstName = $mgUser.GivenName 
$locationHired = $mgUser.OfficeLocation 
$Manager = $path
$newUserOU = $newUserPath 
$surName = $mgUser.Surname 
$acctSamName = $mgUser.GivenName + "."+$mgUser.Surname






            #Standardizes and Sanitizes the User Information 
            $firstName = $firstName.trim()

            #This is to handle last names with a space or hyphen
            If ($firstName -match " ")
                {
                    Write-Output "First Name is: $firstName"
	                Write-Output "This has a space"
                    $firstName = $firstName.split(" ")
                    Write-Output "Post Split it is $firstName"
                    $firstName = $firstName[0].substring(0,1).toUpper()+$firstName[0].substring(1).toLower()+" "+$firstName[1].substring(0,1).toUpper()+$firstName[1].substring(1).toLower()
                    Write-Output "Post Edits it is $firstName"
                    $firstName = $firstName.Trim()
                    Write-Output "Post Trim First Name is $firstName"
                    $firstNameUPN = $firstName.Replace(" ","").Trim()
                    Write-Output "First Name for UPN is $firstNameUPN"
	            }
		
		
            ElseIf($firstName -match "-")
                {
	                Write-Output "This is hyphenated"
                    $firstName = $firstName.split("-")
                    Write-Output "Post Split it is $firstName"
                    $firstName = $firstName[0].substring(0,1).toUpper()+$firstName[0].substring(1).toLower()+"-"+$firstName[1].substring(0,1).toUpper()+$firstName[1].substring(1).toLower()
                    Write-Output "Post Edits it is $firstName"
                    $firstName = $firstName.Trim()
                    Write-Output "Post Trim First Name is $firstName"
                    $firstNameUPN = $firstName.trim()
                    Write-Output "Last Name for UPN is $firstNameUPN"
	            }
            #If their First Name is not Hyphenated or does not contain a space, it does not get modified.
            Else
            {
            $firstNameUPN = $firstName.SubString(0,1) +$FirstName.SubString(1).ToLower()
            }
		



            $lastName = $surName.trim()
            #This is to handle last names with a space or hyphen
            If ($lastName -match " ")
                {
                    Write-Output "Last Name is: $lastName"
	                Write-Output "This has a space"
                    $lastName = $lastName.split(" ")
                    Write-Output "Post Split it is $lastName"
                    $lastName = $lastName[0].substring(0,1).toUpper()+$lastName[0].substring(1).toLower()+" "+$lastName[1].substring(0,1).toUpper()+$lastName[1].substring(1).toLower()
                    Write-Output "Post Edits it is $lastName"
                    $lastName = $lastName.Trim()
                    Write-Output "Post Trim Last Name is $lastName"
                    $lastNameUPN = $lastName.Replace(" ","").Trim()
                    Write-Output "Last Name for UPN is $lastNameUPN"
	            }
		
		
            ElseIf($lastName -match "-")
                {
	                Write-Output "This is hyphenated"
                    $lastName = $lastName.split("-")
                    Write-Output "Post Split it is $lastName"
                    $lastName = $lastName[0].substring(0,1).toUpper()+$lastName[0].substring(1).toLower()+"-"+$lastName[1].substring(0,1).toUpper()+$lastName[1].substring(1).toLower()
                    Write-Output "Post Edits it is $lastName"
                    $lastName = $lastName.Trim()
                    Write-Output "Post Trim Last Name is $lastName"
                    $lastNameUPN = $lastName.trim()
                    Write-Output "Last Name for UPN is $lastNameUPN"
	            }
            Else
            {
            $lastNameUPN = $lastName.SubString(0,1) +$lastName.SubString(1).ToLower()
            }
		


            #Proper casing for job title
            $jobtitle = $jobtitle.substring(0,1).toUpper()+$jobtitle.substring(1).toLower()
            $jobtitle = $jobtitle.trim()
            $TextInfo = (Get-Culture).TextInfo
            $jobtitle = $TextInfo.ToTitleCase($jobtitle)




            #Set their mail nickname with proper casing
            $mailNN = $firstnameUPN + "."+$lastNameUPN
            $mailNN = $mailNN.trim()

            #Set their displayname with proper casing 
            $displayName = $firstname + " " +$lastname
            $displayName = $displayName.trim()
            $displayName = $TextInfo.ToTitleCase($displayName)


New-ADUser -Enabled $true `
            -name $displayName `
            -Country $usageLoc `
            -DisplayName $displayName `
            -UserPrincipalName $emailAddr `
            -OfficePhone $businessPhone `
            -Company $company `
            -Title $jobtitle `
            -AccountPassword $password `
            -Department $DepartmentString `
            -GivenName $firstName `
            -Office $locationHired `
            -Manager $manager `
            -Path $newUserOU `
            -Surname $lastName `
            -SamAccountName $acctSAMName -erroraction Stop

$locADUser = Get-ADUser $acctSamName


$extensionAttributes = $mgUser.OnPremisesExtensionAttributes
$extAttr1 = $extensionAttributes.ExtensionAttribute1

If ($null -ne $extAttr1)
{
    set-aduser $locADUser -add @{"extensionAttribute1"=$extAttr1}
}
Else
{
    Write-Output "Nothing is set for their Extension Attribute 1 which determines if they are a shop or office user"
}
ForEach ($proxyAddress in $mailbox.EmailAddresses)
{
    set-aduser $locADUser -add @{"proxyAddresses"="smtp:$proxyAddress"}
}

switch ($usageLoc) {
    "US" {
        $country = "United States"
        $countryCode = "840"

    }
    "BR" {
        $country = "Brazil"
        $countryCode = "076"

    }
    "CA" {
        $country = "Canada"
        $countryCode = "124"

    }
    "ZA" {
        $country = "South Africa"
        $countryCode = "710"

    }
    "MY" {
        $country = "Malaysia"
        $countryCode = "458"

    }
    "IT"{
        $country = "Italy"
        $countryCode = "380"

    }
    "ES" {
        $country = "Spain"
        $countryCode = "724"

    }
    "CN" {
        $country = "China"
        $countryCode = "156"

    }
    "BE" {
        $country = "Belgium"
        $countryCode = "056"

    }
    "AU" {
        $country = "Australia"
        $countryCode = "036"

    }
    "DE" {
        $country = "Germany"
        $countryCode = "276"

    }
    "DK" {
        $country = "Denmark"
        $countryCode = "208"

    }
    "VN" {
        $country = "Vietnam"
        $countryCode = "704"

    }
    "AE" {
        $country = "United Arab Emirates"
        $countryCode = "784"

    }
    "GB" {
        $country = "United Kingdom"
        $countryCode = "826"

    }
    "AT" {
        $country = "Austria"
        $countryCode = "040"

    }
    Default {$null}
}

set-aduser $locADUser -Replace @{c="$usageLoc";co="$country";countrycode=$countryCode}
Get-ADUser $acctSamName -Properties *
# SIG # Begin signature block#Script Signature# SIG # End signature block




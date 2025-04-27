Clear-Host
Connect-MgGraph 
$process = "CompuData Taneytown User Creation"
$allStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | Starting [$process]"

$compuDataUsers = Import-CSV -Path "\\uniqueParentCompanyusers\departments\Public\Tech-Items\Script Configs\compuDataUsers2.csv"
$errorUsers = @()



ForEach ($user in $compuDataUsers)
{
    #reset variables.
    $firstName          = $null
    $middleInitial      = $null
    $lastName           = $null
    $mailNN             = $null
    $DoW                = $null
    $Month              = $null
    $Day                = $null
    $pw                 = $null
    $password           = $null 
    $displayName        = $null
    $splits             = $null
    $lastNameArray      = $null
    $acctSAMName        = $null
    $UPN                = $null
    $procProcess        = $null
    $failTimerEnd       = $null
    $procStartTime      = $null
    $procEndTime        = $null
    $procNetTime        = $null
    $currTime           = $null










    try
    {
        $currTime = Get-Date -format "HH:mm"
         #Start
        $procStartTime = Get-Date 
        $currTime = Get-Date -format "HH:mm"
        $procProcess = "User Variable Construction"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] starting"


        If ($user.'uniqueParentCompany Location' -eq 'TT (TaneyTown) Users')
        {
            Write-Output "Skipping $($User.users) as they are a Taneytown User"
            $errorUsers+= [PSCustomObject]@{
                failedUser      = $user.Users
                ReasonFailed    = "Already exists as a TT User"
            }
            #Proceed to the next user
            continue 
        }
        Else
        {
            Write-Output "Construcing Variables for $($User.users)"
            #Password Generation 
            $date = get-date
            $DoW = $date.DayOfWeek.ToString()
            $Month = (Get-date $date -format "MM").ToString()
            $Day = (Get-date $date -format "dd").ToString()
            $pw = $DoW+$Month+$Day+"!"
            $password = ConvertTo-SecureString -string "$pw" -AsPlainText -Force
            
            
            #User Generated Parameters
            $displayName = $user.Users

            #If their displayName is already firstName lastName add here
            if ($user.Users.Split(" ").count -le 2)
            {
                Write-Output "$($User.users) is in First Last Notation"
                $firstName = $user.Users.Split(" ")[0].trim()
                $lastName = $user.Users.Split(" ")[1].trim()
                $mailNN = $firstName +"."+$lastName
                $mailNN = $mailNN.trim()

                If ($mailNN.length -gt 20)
                    {
                        Write-Output "$($User.users) acctSAMName is too long. Dropping Down."    
                        $acctSAMName = $mailNN.substring(0,20)
                    }
                    Else
                    {
                        Write-Output "$($User.users) acctSAMName is compliant." 
                        $acctSAMName = $mailNN
                    }

            }
            
            #If their displayName has either a middle initial or a space, construct it here.
            else 
            {
                Write-Output "$($User.users) requires Further Evaluation"
                $splits=$user.Users.Split(" ")
                

                $FirstName = $user.Users.Split(" ")[0].trim()

                #If there is a period after the character in the second item of the array it is a middle initial and is added here.
                if ($splits[1] -like "*.*")
                {
                    Write-Output "$($User.users) is in First Middle Last Notation"
                    #Set the middle initial
                    $middleInitial = $splits[1]
                    $lastNameArray = $splits[2..$splits.count]
                    ForEAch ($part in $lastNameArray)
                    {   
                        $lastName += $part+" "
                        
                    }
                    $lastNameUPN = $lastName.Replace(" ","").Trim()
                    $lastName = $lastName.trim()                    


                    
                    #SAM Account Name Generation Done Here
                    $mailNN = $FirstName + "."+$middleInitial+"."+$lastNameUPN
                    $mailNN = $mailNN.trim()

                    If ($mailNN.length -gt 20)
                    {
                        Write-Output "$($User.users) acctSAMName is too long. Dropping Down."    
                        $acctSAMName = $mailNN.substring(0,20)
                    }
                    Else
                    {
                        Write-Output "$($User.users) acctSAMName is compliant." 
                        $acctSAMName = $mailNN
                    }
                }
                
                #If there is not a period indicating a middle initial, their name has spaces and will be modified accordingly.
                Else
                {
                    Write-Output "$($User.users) is in First Last Notation with a Special Last Name"
                    $lastNameArray = $splits[1..$splits.count]
                    ForEAch ($part in $lastNameArray)
                    {   
                        $lastName += $part+" "
                        
                    }
                    $lastNameUPN = $lastName.Replace(" ","").Trim()
                    $lastName = $lastName.trim()
                    
                    #SAM Account Generation
                    $mailNN = $firstName+"."+$lastNAmeUPN
                    $mailNN = $mailNN.trim()
        
                    If ($mailNN.length -gt 20)
                    {
                        Write-Output "$($User.users) acctSAMName is too long. Dropping Down."
                        $acctSAMName = $mailNN.substring(0,20)
                    }
                    Else
                    {
                        Write-Output "$($User.users) acctSAMName is compliant."
                        $acctSAMName = $mailNN
                    }

                }

                
                
            }
            #Gets their primary graph email attribute
            $graphUser = Get-MGUser -ConsistencyLevel eventual -search "UserPrincipalName:$acctSAMNAme"
            if ($graphUser.mail.count -ge 2)
            {
                $email = $graphUser.Mail[0]
            }
            Else
            {
                $email = $graphUser.mail
            }
            

            


            #Create the UPN
            $UPN = $user.'Primary Local AD'.split('@')[0]+"@uniqueParentCompany.com"
            
            $procEndTime = Get-Date
            $procNetTime = $procEndTime - $procStartTime
            Write-Output "[$($currTime)] | [$process] | [$procProcess] to complete: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"


            #Start
            $procStartTime = Get-Date 
            $currTime = Get-Date -format "HH:mm"
            $procProcess = "User Creation"
            Write-Output "[$($currTime)] | [$process] | [$procProcess] starting"


            Write-Output "`User being created"
            Write-Output "Name: $displayName" 
            Write-Output "Country: US" 
            Write-Output "DisplayName: $displayName" 
            Write-Output "UserPrincipalName: $UPN"
            Write-Output "OfficePhone: 14107562600" 
            Write-Output "Company: Not Affiliated"
            Write-Output "Title: DocLink User"
            Write-Output "Password: $password"
            Write-Output "Department: Service Account" 
            Write-Output "GivenName: $firstName" 
            Write-Output "Office: unique-Office-Location-0" 
            Write-Output "New User Path: OU=CompuData - External Sage Users - Non-Synching,DC=uniqueParentCompany,DC=COM" 
            Write-Output "Surname: $lastName"
            Write-Output "Server: uniqueParentCompany.COM" 
            Write-Output "SamAccountName: $acctSAMName `n`n`n" 

            #Create the new user here 
            New-ADUser -Enabled $true `
            -name $displayName `
            -Country "US" `
            -DisplayName $displayName `
            -UserPrincipalName $UPN `
            -OfficePhone "14107562600" `
            -Company "Not Affiliated"`
            -Title "DocLink User"`
            -AccountPassword $password `
            -Department "Service Account" `
            -GivenName $firstName `
            -Office "unique-Office-Location-0" `
            -Path "OU=CompuData - External Sage Users - Non-Synching,DC=uniqueParentCompany,DC=COM" `
            -Surname $lastName `
            -Server "uniqueParentCompany.COM" `
            -EmailAddress $email `
            -SamAccountName $acctSAMName -erroraction Stop

            $currTime = Get-Date -format "HH:mm"
            $procEndTime = Get-Date
            $procNetTime = $procEndTime - $procStartTime
            Write-Output "[$($currTime)] | [$process] | [$procProcess] to complete: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"


            $compuDataGroup1 = Get-ADGroup -Identity "Citrix Cloud W11M Desktop Users" -server 'uniqueParentCompany.com'
            $compuDataGroup2 = Get-ADGroup -Identity "DocLink Users" -Server 'uniqueParentCompany.Com'
            Add-ADGroupMember -identity $compuDataGroup1 -members $acctSAMName
            Add-ADGroupMember -identity $compuDataGroup2 -members $acctSAMName
            Set-ADUser $acctSAMName -ChangePasswordAtLogon $true

        } 

    }

    
    catch 
    {
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] Error hit for $($User.users)"
        $failTimerEnd = Get-Date
        $errorUsers+= [PSCustomObject]@{
            FailedUser          = $user.Users
            processFailed       = $procProcess
            timeToFail          = $failTimerEnd
            ReasonFailed        = $error[0]
        }
    }
        
}
$allEndTime = Get-Date
$allNetTime = $allEndTime - $allStartTime
Write-Output "[$($currTime)] | [$process] | Time taken for [$process] to complete: $($allNetTime.hours) hours, $($allNetTime.minutes) minutes, $($allNetTime.seconds) seconds"
# SIG # Begin signature block#Script Signature# SIG # End signature block






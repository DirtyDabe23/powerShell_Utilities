$compuDataUsers = Import-CSV -Path "\\uniqueParentCompanyusers\departments\Public\Tech-Items\Script Configs\compuDataUsers.csv"
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
    $newUserOU          = $null
    $UPN                = $null








    try
    {
        If ($user.'uniqueParentCompany Location' -eq 'TT (Location) Users')
        {
            $errorUsers+= [PSCustomObject]@{
                failedUser      = $user.Users
                ReasonFailed    = "Already exists as a TT User"
            }
        }
        Else
        {
            #Password Generation 
            $DoW = $date.DayOfWeek.ToString()
            $Month = (Get-date $date -format "MM").ToString()
            $Day = (Get-date $date -format "dd").ToString()
            $pw = $DoW+$Month+$Day+"!"
            $password = ConvertTo-SecureString -string "$pw" -AsPlainText -Force
            
            
            #User Generated Parameters
            $displayName = $user.Users

            #If their displayName is already firstName lastName add here
            if ($user.Users.Split(" ") -le 2)
            {
                $firstName = $user.Users.Split(" ")[0].trim()
                $lastName = $user.Users.Split(" ")[1].trim()
            }
            
            #If their displayName has either a middle initial or a space, construct it here.
            else 
            {
                $splits=$user.Users.Split(" ")
                

                $FirstName = $user.Users.Split(" ")[0].trim()

                #If there is a period after the character in the second item of the array it is a middle initial and is added here.
                if ($splits[1] -like "*.*")
                {
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
                    $acctSAMName = $mailNN.substring(0,20)
                    }
                    Else
                    {
                    $acctSAMName = $mailNN
                    }
                }
                
                #If there is not a period indicating a middle initial, their name has spaces and will be modified accordingly.
                Else
                {
                    $lastNameArray = $splits[1..$splits.count]
                    ForEAch ($part in $lastNameArray)
                    {   
                        $lastName += $part+" "
                        
                    }
                    $lastNameUPN = $lastName.Replace(" ","").Trim()
                    $lastName = $lastName.trim()
                    
                    #SAM Account Generation
                    $mailNN = $FirstName +"."+$lastNameUPN
                    $mailNN = $mailNN.trim()
        
                    If ($mailNN.length -gt 20)
                    {
                        $acctSAMName = $mailNN.substring(0,20)
                    }
                    Else
                    {
                        $acctSAMName = $mailNN
                    }

                }

                
                
            }
            

            


            #Create the UPN
            $UPN = $user.'Primary Local AD'+"@uniqueParentCompany.com"
            

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
            -Path $newUserOU `
            -Surname $lastName `
            -Server "uniqueParentCompany.COM" `
            -SamAccountName $acctSAMName -erroraction Stop
            
    
        } 

    }

    
    catch 
    {
        $errorUsers+= [PSCustomObject]@{
            FailedUser      = $user.Users
            ReasonFailed    = $error[0]
        }
    }
        
}

# SIG # Begin signature block#Script Signature# SIG # End signature block







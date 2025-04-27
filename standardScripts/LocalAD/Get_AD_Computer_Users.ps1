#Enter credentials for domain admin account
$cred = Get-Credential
#Pulls all the computers 
$computers = Get-ADComputer -filter * -Properties * | Where-Object {($_.LastLogonDate -gt (Get-Date).AddDays(-90))} |Select-Object -Property "Name", "LastLogonDate" | sort-object -Property "Name"
#Initializes the object to store all values
$logonData = @()
#Counter for Tracking
$counter = 1

#FileShare to export the CSV 
$shareLoc = "\\uniqueParentCompanyusers\departments\Public\Tech-Items\scriptLogs\"
$fileName = "userLogins.csv"
$dateTime = Get-Date -Format yyyy.MM.dd.HH.mm

#Time tracking for how long this process takes
$Start_Time = Get-Date 

ForEach ($computer in $computers)
{
    #information logging
    $currTime = Get-Date -format "HH:mm"
    Write-Host "[$($currTime)] | $counter/$($computers.count) | Checking: $($computer.Name)"

    #Tests to see if the computer can be connected to remotely, if it can, it proceeds, otherwise it sets all values to null
    If (Test-Connection -ComputerName $computer.name -ErrorAction SilentlyContinue -Count 1)
    {
        #Gets the IP Address
        $endpointIP = (test-connection -ComputerName $computer.name -count 1).IPV4Address.ipaddresstostring
        
        If(Test-WSMan -computer $computer.Name -erroraction SilentlyContinue) 
        {
            #Creates session data per endpoint
            try
            {
            $session = New-PSSession -ComputerName $computer.name -Credential $cred -ErrorAction Stop
            }
            catch
            {
                $logonData += [PSCustomObject]@{
                    computerName                                        = $computer.Name
                    computerUser                                        = "Unable to Assess"
                    computerIPV4Address                                 = $endpointIP
                    pingResponse                                        = "Successful"
                    winRMStatus                                         = "Successful"
                    psSessionStatus                                     = "Failed"
                                                        }  
            $counter++
            continue
            }
            try
            {
                $loggedonUser  = Invoke-Command -Session $session  {Get-Ciminstance -ClassName Win32_ComputerSystem | Select-Object UserName} -ErrorAction Stop
                $loggedonusername = $loggedonuser.username 
                $userwithoutdomain = $loggedonusername -replace "^.*?\\"
                $textInfo = (Get-Culture).TextInfo
                $userwithoutdomain = $textInfo.ToTitleCase($userwithoutDomain.replace("."," "))

            }
            catch
            {
                $userwithoutdomain = "No Logged In User"
            }

                $logonData += [PSCustomObject]@{
                    computerName                                        = $computer.Name
                    computerUser                                        = $userwithoutdomain
                    computerIPV4Address                                 = $endpointIP
                    pingResponse                                        = "Successful"
                    winRMStatus                                         = "Successful"
                    psSessionStatus                                     = "Successful"
                    
                                            }
            $counter++
            continue  
        }
    
        
        else
        {
            $logonData += [PSCustomObject]@{
                computerName                                        = $computer.Name
                computerUser                                        = "Unable to Assess"
                computerIPV4Address                                 = $endpointIP
                pingResponse                                        = "Successful"
                winRMStatus                                         = "Failed"
                psSessionStatus                                     = "Unable to Assess"
                                        }
        }
    }
    else 
    {
        #Gets the IP Address
        $endpointIP = (test-connection -ComputerName $computer.name -erroraction SilentlyContinue -count 1).IPV4Address.ipaddresstostring 
        
    
        $logonData += [PSCustomObject]@{
            computerName                                        = $computer.Name
            computerUser                                        = "Unable to Assess"
            computerIPV4Address                                 = $endpointIP
            pingResponse                                        = "Uanble to Ping"
            winRMStatus                                         = "Unable to Assess"
            psSessionStatus                                     = "Unable to Assess"
                                    }
    }
$counter++
}
$endTime = Get-Date
$netTime = $endTime - $start_Time 
Write-Output "[$($currTime)] | Time taken for [User Login] to complete: $($netTime.hours) hours, $($netTime.minutes) minutes, $($netTime.seconds) seconds"

$exportPath = $shareLoc+$dateTime+"."+$fileName

$logonData | export-csv -path $exportPath
$logonData

# SIG # Begin signature block#Script Signature# SIG # End signature block





#Enter credentials for domain admin account
$cred = Get-Credential
#Pulls all the computers 
$computers = Get-ADComputer -filter * -Properties * | Where-Object {($_.LastLogonDate -gt (Get-Date).AddDays(-90))} |Select-Object -Property "Name", "LastLogonDate" | sort-object -Property "Name"
#Initializes the object to store all values
$printerData = @()
#Counter for Tracking
$counter = 1

#FileShare to export the CSV 
$shareLoc = "\\uniqueParentCompanyusers\departments\Public\Tech-Items\scriptLogs\"
$fileName = "printerInfoData.csv"
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
                $printerData += [PSCustomObject]@{
                    computerName                                        = $computer.Name
                    computerUser                                        = "Unable to Assess"
                    computerIPV4Address                                 = $endpointIP
                    pingResponse                                        = "Successful"
                    winRMStatus                                         = "Successful"
                    psSessionStatus                                     = "Failed"
                    getPrinterStatus                                    = "Unable to Assess"
                    printerName                                         = "Unable To Assess"
                    printerType                                         = "Unable To Assess"           
                    printerShareName                                    = "Unable To Assess"        
                    printerPortName                                     = "Unable To Assess"        
                    printerDriverName                                   = "Unable To Assess"                   
                    printerLocation                                     = "Unable To Assess"        
                    printerComment                                      = "Unable To Assess"        
                    printerSeparatorPageFile                            = "Unable To Assess"        
                    printerPrintProcessor                               = "Unable To Assess"
                    printerDatatype                                     = "Unable To Assess"
                    printerShared                                       = "Unable To Assess"
                    printerPublished                                    = "Unable To Assess"
                    printerDeviceType                                   = "Unable To Assess"
                    printerPermissionSDDL                               = "Unable To Assess"
                    printerRenderingMode                                = "Unable To Assess"
                    printerKeepPrintedJobs                              = "Unable To Assess"
                    printerPriority                                     = "Unable To Assess"
                    printerDefaultJobPriority                           = "Unable To Assess"
                    printerStartTime                                    = "Unable To Assess"
                    printerUntilTime                                    = "Unable To Assess"
                    printerPrinterStatus                                = "Unable To Assess"
                    printerJobCount                                     = "Unable To Assess"
                    printerDisableBranchOfficeLogging                   = "Unable To Assess"
                    printerBranchOfficeOfflineLogSizeMB                 = "Unable To Assess"
                    printerWorkflowPolicy                               = "Unable To Assess"
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
            #Gets the printers  on the endpoints.
            try 
            {
                $printers = Get-Printer -ComputerName $computer.name -Full -ErrorAction Stop | format-list
            }
            catch 
            {
                $printerData += [PSCustomObject]@{
                    computerName                                        = $computer.Name
                    computerUser                                        = $userwithoutdomain
                    computerIPV4Address                                 = $endpointIP
                    pingResponse                                        = "Successful"
                    winRMStatus                                         = "Successful"
                    psSessionStatus                                     = "Successful"
                    getPrinterStatus                                    = "Failed"
                    printerName                                         = "Unable To Assess"
                    printerType                                         = "Unable To Assess"           
                    printerShareName                                    = "Unable To Assess"        
                    printerPortName                                     = "Unable To Assess"        
                    printerDriverName                                   = "Unable To Assess"                   
                    printerLocation                                     = "Unable To Assess"        
                    printerComment                                      = "Unable To Assess"        
                    printerSeparatorPageFile                            = "Unable To Assess"        
                    printerPrintProcessor                               = "Unable To Assess"
                    printerDatatype                                     = "Unable To Assess"
                    printerShared                                       = "Unable To Assess"
                    printerPublished                                    = "Unable To Assess"
                    printerDeviceType                                   = "Unable To Assess"
                    printerPermissionSDDL                               = "Unable To Assess"
                    printerRenderingMode                                = "Unable To Assess"
                    printerKeepPrintedJobs                              = "Unable To Assess"
                    printerPriority                                     = "Unable To Assess"
                    printerDefaultJobPriority                           = "Unable To Assess"
                    printerStartTime                                    = "Unable To Assess"
                    printerUntilTime                                    = "Unable To Assess"
                    printerPrinterStatus                                = "Unable To Assess"
                    printerJobCount                                     = "Unable To Assess"
                    printerDisableBranchOfficeLogging                   = "Unable To Assess"
                    printerBranchOfficeOfflineLogSizeMB                 = "Unable To Assess"
                    printerWorkflowPolicy                               = "Unable To Assess"
                                            }
            $counter++
            continue  
            }
            
            
            

                #Addresses every adapter individually 
                ForEach ($printer in $printers)
                {
                    
                    #Load the values into the object
                    $printerData += [PSCustomObject]@{
                        computerName                                        = $computer.Name
                        computerUser                                        = $userwithoutdomain
                        computerIPV4Address                                 = $endpointIP
                        pingResponse                                        = "Successful"
                        winRMStatus                                         = "Successful"
                        psSessionStatus                                     = "Successful"
                        getPrinterStatus                                    = "Successful"
                        printerName                                         = $printer.Name
                        printerType                                         = $printer.Type         
                        printerShareName                                    = $printer.ShareName       
                        printerPortName                                     = $printer.PortName        
                        printerDriverName                                   = $printer.DriverName                   
                        printerLocation                                     = $printer.Location       
                        printerComment                                      = $printer.Comment        
                        printerSeparatorPageFile                            = $printer.SeparatorPageFile        
                        printerPrintProcessor                               = $printer.PrintProcessor
                        printerDatatype                                     = $printer.Datatype
                        printerShared                                       = $printer.Shared
                        printerPublished                                    = $printer.Published
                        printerDeviceType                                   = $printer.DeviceType
                        printerPermissionSDDL                               = $printer.PermissionSDDL
                        printerRenderingMode                                = $printer.RenderingMode
                        printerKeepPrintedJobs                              = $printer.KeepPrintedJobs
                        printerPriority                                     = $printer.priority
                        printerDefaultJobPriority                           = $printer.DefaultJobPriority
                        printerStartTime                                    = $printer.StartTime
                        printerUntilTime                                    = $printer.UntilTime
                        printerPrinterStatus                                = $printer.PrinterStatus
                        printerJobCount                                     = $printer.JobCount
                        printerDisableBranchOfficeLogging                   = $printer.DisableBranchOfficeLogging
                        printerBranchOfficeOfflineLogSizeMB                 = $printer.BranchOfficeOfflineLogSizeMB
                        printerWorkflowPolicy                               = $printer.WorkflowPolicy
                                                } 
                }

            
    #increment the counter

        }
        
        else
        {
            $printerData += [PSCustomObject]@{
                computerName                                        = $computer.Name
                computerUser                                        = "Unable to Assess"
                computerIPV4Address                                 = $endpointIP
                pingResponse                                        = "Successful"
                winRMStatus                                         = "Failed"
                psSessionStatus                                     = "Unable to Assess"
                getPrinterStatus                                    = "Unable to Assess"
                printerName                                         = "Unable To Assess"
                printerType                                         = "Unable To Assess"           
                printerShareName                                    = "Unable To Assess"        
                printerPortName                                     = "Unable To Assess"        
                printerDriverName                                   = "Unable To Assess"                   
                printerLocation                                     = "Unable To Assess"        
                printerComment                                      = "Unable To Assess"        
                printerSeparatorPageFile                            = "Unable To Assess"        
                printerPrintProcessor                               = "Unable To Assess"
                printerDatatype                                     = "Unable To Assess"
                printerShared                                       = "Unable To Assess"
                printerPublished                                    = "Unable To Assess"
                printerDeviceType                                   = "Unable To Assess"
                printerPermissionSDDL                               = "Unable To Assess"
                printerRenderingMode                                = "Unable To Assess"
                printerKeepPrintedJobs                              = "Unable To Assess"
                printerPriority                                     = "Unable To Assess"
                printerDefaultJobPriority                           = "Unable To Assess"
                printerStartTime                                    = "Unable To Assess"
                printerUntilTime                                    = "Unable To Assess"
                printerPrinterStatus                                = "Unable To Assess"
                printerJobCount                                     = "Unable To Assess"
                printerDisableBranchOfficeLogging                   = "Unable To Assess"
                printerBranchOfficeOfflineLogSizeMB                 = "Unable To Assess"
                printerWorkflowPolicy                               = "Unable To Assess"
                                        }
                                    }
    }
    else 
    {
        #Gets the IP Address
        $endpointIP = (test-connection -ComputerName $computer.name -erroraction SilentlyContinue -count 1).IPV4Address.ipaddresstostring 
        
    
        $printerData += [PSCustomObject]@{
            computerName                                        = $computer.Name
            computerUser                                        = "Unable to Assess"
            computerIPV4Address                                 = $endpointIP
            pingResponse                                        = "Uanble to Ping"
            winRMStatus                                         = "Unable to Assess"
            psSessionStatus                                     = "Unable to Assess"
            getPrinterStatus                                    = "Unable to Assess"
            printerName                                         = "Unable To Assess"
            printerType                                         = "Unable To Assess"           
            printerShareName                                    = "Unable To Assess"        
            printerPortName                                     = "Unable To Assess"        
            printerDriverName                                   = "Unable To Assess"                   
            printerLocation                                     = "Unable To Assess"        
            printerComment                                      = "Unable To Assess"        
            printerSeparatorPageFile                            = "Unable To Assess"        
            printerPrintProcessor                               = "Unable To Assess"
            printerDatatype                                     = "Unable To Assess"
            printerShared                                       = "Unable To Assess"
            printerPublished                                    = "Unable To Assess"
            printerDeviceType                                   = "Unable To Assess"
            printerPermissionSDDL                               = "Unable To Assess"
            printerRenderingMode                                = "Unable To Assess"
            printerKeepPrintedJobs                              = "Unable To Assess"
            printerPriority                                     = "Unable To Assess"
            printerDefaultJobPriority                           = "Unable To Assess"
            printerStartTime                                    = "Unable To Assess"
            printerUntilTime                                    = "Unable To Assess"
            printerPrinterStatus                                = "Unable To Assess"
            printerJobCount                                     = "Unable To Assess"
            printerDisableBranchOfficeLogging                   = "Unable To Assess"
            printerBranchOfficeOfflineLogSizeMB                 = "Unable To Assess"
            printerWorkflowPolicy                               = "Unable To Assess"
                                    }
    }
$counter++
}
$endTime = Get-Date
$netTime = $endTime - $start_Time 
Write-Output "[$($currTime)] | Time taken for [Printer Audit] to complete: $($netTime.hours) hours, $($netTime.minutes) minutes, $($netTime.seconds) seconds"

$exportPath = $shareLoc+$dateTime+"."+$fileName

$printerData | export-csv -path $exportPath
$printerData

# SIG # Begin signature block#Script Signature# SIG # End signature block





Clear-Host
$logName = Read-Host "Enter the LogName to review"
$ID = Read-Host "Enter the ID to review"
$inputSelection = Read-Host "Please Select the time formatting, Default is Minutes`n1: Day`n2: Hour `n3: Minute"
switch ($inputSelection) {
    1 {
        [int]$numberSelection = Read-Host "Enter the number of days back to select"
        $backSelection = $numberSelection * -1
        $startTime = (Get-Date).AddDays($backSelection) 
    }
    2 {
        [int]$numberSelection = Read-Host "Enter the number of hours back to select"
        $backSelection = $numberSelection * -1
        $startTime = (Get-Date).AddHours($backSelection) 

    }
    3 {
        [int]$numberSelection = Read-Host "Enter the number of minutes back to select"
        $backSelection = $numberSelection * -1
        $startTime = (Get-Date).AddMinutes($backSelection) 

    }
    Default {
        [int]$numberSelection = Read-Host "Enter the number of minutes back to select"
        $backSelection = $numberSelection * -1
        $startTime = (Get-Date).AddMinutes($backSelection)  
    }
}
get-winevent -FilterHashtable @{ LogName =$logName; StartTime=$startTime; id=$ID} | Select-Object * | more



# SIG # Begin signature block#Script Signature# SIG # End signature block




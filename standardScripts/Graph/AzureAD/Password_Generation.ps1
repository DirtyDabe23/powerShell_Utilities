$date = $uData.customfield_10613
$date = get-date $date

$DoW = $date.DayOfWeek.ToString()
$Month = (Get-date $udata.customfield_10613 -format "MM").ToString()
$Day = $date.Day.ToString()
$pw = $DoW+$Month+$Day+"!"


 $PasswordProfile = @{
    
                Password = $pw
                  }



# SIG # Begin signature block#Script Signature# SIG # End signature block





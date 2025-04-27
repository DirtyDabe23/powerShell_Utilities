#Items that define how the scheduled task is created.
$scheduledTasks = Import-CSV -Path "\\uniqueParentCompanyusers\departments\public\tech-items\Script Configs\Scheduled_Tasks.csv"
$user = 'uniqueParentCompany\$userNameadmin'

ForEach ($scheduledTask in $scheduledTasks)
{
    [array]$DoW = $null
    

    switch ($scheduledTask.Frequency)
    {
        'Hourly'{
            $interval = New-TimeSpan -Hours 1
            $duration = New-TimeSpan -Days 9999
            $Trigger = New-ScheduledTaskTrigger -Once -At $scheduledTask.Start_Time -RepetitionInterval $interval -RepetitionDuration $duration
        }
        
        'Daily'{
            $Trigger = New-ScheduledTaskTrigger -Daily -At $scheduledTask.Start_Time 
        }
        'WorkDays'{
            if ($scheduledTask.Monday -eq 'Y') { $DoW += 'Monday' }
            if ($scheduledTask.Tuesday -eq 'Y') { $DoW += 'Tuesday' }
            if ($scheduledTask.Wednesday -eq 'Y') { $DoW += 'Wednesday' }
            if ($scheduledTask.Thursday -eq 'Y') { $DoW += 'Thursday' }
            if ($scheduledTask.Friday -eq 'Y') { $DoW += 'Friday' }
            if ($scheduledTask.Saturday -eq 'Y') { $DoW += 'Saturday' }
            if ($scheduledTask.Sunday -eq 'Y') { $DoW += 'Sunday' }
            $Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $DoW -At $scheduledTask.Start_Time    
        }
    }

    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NonInteractive -WindowStyle Hidden -File $($scheduledTask.Script)"
    $Settings = New-ScheduledTaskSettingsSet -Compatibility Win8
    Register-ScheduledTask -TaskName $scheduledTask.TaskName -Trigger $Trigger -User $user -Action $Action -Settings $Settings -RunLevel Highest -Force
}
# SIG # Begin signature block#Script Signature# SIG # End signature block






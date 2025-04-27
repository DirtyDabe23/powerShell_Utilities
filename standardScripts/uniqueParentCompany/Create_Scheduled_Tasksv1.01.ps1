# Import the scheduled tasks from the CSV file
$scheduledTasks = Import-CSV -Path "\\uniqueParentCompanyusers\departments\public\tech-items\Script Configs\Scheduled_Tasks.csv"

# Specify the user account to run the scheduled tasks
$user = "$userNameadmin@uniqueParentCompany.com"
$password = Read-Host -Prompt "Enter your password" -AsSecureString


# Loop through each scheduled task in the CSV file
ForEach ($scheduledTask in $scheduledTasks)
{
    # Initialize the days of the week array to null
    [array]$DoW = @()
    
    # Determine the frequency and create the appropriate trigger
    switch ($scheduledTask.Frequency)
    {
        'Hourly'{
            $interval = New-TimeSpan -Hours 1
            $duration = [TimeSpan]::MaxValue # Indefinitely
            $Trigger = New-ScheduledTaskTrigger -Once -At $scheduledTask.Start_Time -RepetitionInterval $interval -RepetitionDuration $duration
        }
        
        'Daily'{
            $Trigger = New-ScheduledTaskTrigger -Daily -At $scheduledTask.Start_Time
        }
        
        'WorkDays'{
            # Add the days of the week to the array based on the CSV columns
            if ($scheduledTask.Monday -eq 'Y') { $DoW += 'Monday' }
            if ($scheduledTask.Tuesday -eq 'Y') { $DoW += 'Tuesday' }
            if ($scheduledTask.Wednesday -eq 'Y') { $DoW += 'Wednesday' }
            if ($scheduledTask.Thursday -eq 'Y') { $DoW += 'Thursday' }
            if ($scheduledTask.Friday -eq 'Y') { $DoW += 'Friday' }
            if ($scheduledTask.Saturday -eq 'Y') { $DoW += 'Saturday' }
            if ($scheduledTask.Sunday -eq 'Y') { $DoW += 'Sunday' }
            
            # Ensure that days of the week are specified
            if ($DoW.Count -eq 0) {
                Write-Error "No days of the week specified for weekly trigger for task: $($scheduledTask.TaskName)"
                continue
            }

            # Create a weekly trigger with the specified days of the week and start time
            $Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $DoW -At $scheduledTask.Start_Time
        }
    }

    # Create the action for the scheduled task
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NonInteractive -WindowStyle Hidden -File $($scheduledTask.Script)"
    
    # Create the settings for the scheduled task with the highest compatibility and to run whether a user is logged in or not
    $Settings = New-ScheduledTaskSettingsSet -Compatibility Win8

    $Principal = New-ScheduledTaskPrincipal -Userid $user -LogonType Password -RunLevel Highest
    
    # Register the scheduled task with the specified settings
    Register-ScheduledTask -TaskName $scheduledTask.TaskName -Trigger $Trigger -Action $Action -Settings $Settings -Principal $Principal -Password $password
}

# SIG # Begin signature block#Script Signature# SIG # End signature block






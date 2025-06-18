#Gets all items in C:\Users that aren't Public or Administrator
$users = Get-ChildItem (Join-Path -Path $env:SystemDrive -ChildPath 'Users') -Exclude 'Public', "*ADMIN*"
#The path under each users directory
$Path = "\AppData\Roaming\Spotify"
#The file itself that needs a firewall rule.
$Process = "\Spotify.exe"

if ($null -ne $users) 
{
    foreach ($user in $users) 
    {
        #Concatenate the path for the program, only make a rule if it's installed.
        $progPath = $user.Fullname + $Path + $Process
        if (Test-Path $progPath) 
        {
            
            if (-not (Get-NetFirewallApplicationFilter -Program $progPath -ErrorAction SilentlyContinue).count -lt 12) 
            {
                $ruleName = "Allow $($Process) Inbound for user $($user.Name)"
                $protocols = "UDP", "TCP"  
                ForEach ($Protocol in $protocols)
                {
                    $ruleNameInbound = "Domain: Allow $($Process) Inbound for User $($user.Name)"
                    New-NetFirewallRule -DisplayName $ruleNameInbound -Direction Inbound -Profile Domain -Program $progPath -Action Allow -Protocol $Protocol
                    $ruleNameInbound = "Domain: Allow $($Process) Outbound for User $($user.Name)"
                    New-NetFirewallRule -DisplayName $ruleNameInbound -Direction Outbound -Profile Domain -Program $progPath -Action Allow -Protocol $Protocol

                    $ruleNameInbound = "Private: Allow $($Process) Inbound for User $($user.Name)"
                    New-NetFirewallRule -DisplayName $ruleNameInbound -Direction Inbound -Profile Private -Program $progPath -Action Allow -Protocol $Protocol
                    $ruleNameInbound = "Private: Allow $($Process) Outbound for User $($user.Name)"
                    New-NetFirewallRule -DisplayName $ruleNameInbound -Direction Outbound -Profile Private -Program $progPath -Action Allow -Protocol $Protocol

                    $ruleNameInbound = "Public: Allow $($Process) Inbound for User $($user.Name)"
                    New-NetFirewallRule -DisplayName $ruleNameInbound -Direction Inbound -Profile Public -Program $progPath -Action Allow -Protocol $Protocol
                    $ruleNameInbound = "Public: Allow $($Process) Outbound for User $($user.Name)"
                    New-NetFirewallRule -DisplayName $ruleNameInbound -Direction Outbound -Profile Public -Program $progPath -Action Allow -Protocol $Protocol
                }
            }
        }
    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block






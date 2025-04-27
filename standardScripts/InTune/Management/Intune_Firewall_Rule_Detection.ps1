#Gets all items in C:\Users that aren't Public or Administrator
$users = Get-ChildItem (Join-Path -Path $env:SystemDrive -ChildPath 'Users') -Exclude 'Public', 'ADMINI~*'
#The path under each users directory
$Path = "\AppData\Roaming\Spotify"
#The file itself that needs a firewall rule.
$Process = "\Spotify.exe"

if ($null -ne $users) 
{
    foreach ($user in $users) 
    {
        #Concatenate the path for the program, only make a rule if it's installed.
        $progPath = $user.Fullname + $Path + $Propcess
        if (Test-Path $progPath) 
        {
            
            if (-not (Get-NetFirewallApplicationFilter -Program $progPath -ErrorAction SilentlyContinue).count -lt 4) 
            {
               Exit 0
            }
            Else
            {
                Exit 1
            }
        }
    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




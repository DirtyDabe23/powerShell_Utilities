param(
    [Parameter (Position = 0, HelpMessage = "Enter the Jira Key, Example: GHD-44619")]
    [string]$Key,
    [Parameter(Position = 1 , HelpMessage = "The Ticket Parameters should be passed off here")]
    [String] $originGraphUserID 
)
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Identity.DirectoryManagement
Connect-MgGraph -Identity 
Write-Output "OriginGraphUserID: $originGraphUserID"
Restore-MgDirectoryDeletedItem -DirectoryObjectId $originGraphUserID 
$graphUserExists = $false 
        While (!($graphUserExists)){
            $restoredUser = Get-MGBetaUser -userid $originGraphUserID -erroraction silentlycontinue
            if ($restoredUser){Write-Output "$($restoredUser.DisplayName) is restored"
                $graphUserExists = $true
                
            }
            else{
                Write-output "Waiting for $originGraphUserID to be restored"
                Start-Sleep -Seconds 5
                $restoredUser = $null
                $graphUserExists = $false
               
            }
        }
Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/Users/$originGraphUserID" -Body @{OnPremisesImmutableId = $null}

# SIG # Begin signature block#Script Signature# SIG # End signature block




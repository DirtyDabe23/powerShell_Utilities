function Set-NewUserDataPath {
    [CmdletBinding()]
    param(
    [Parameter(Position = 0, HelpMessage = "Enter the Path of the Current User Data Drive Directory, leading up to their user account. `nExample: \\directory\share\`nEnter",Mandatory = $true)]
    [string]$userDataPath,
    [Parameter(Position = 1, HelpMessage = "Enter the Previous Username`nExample: testUser`nEnter",Mandatory = $true)]
    [string]$previousName,
    [Parameter(Position = 2, HelpMessage = "Enter the New Username`nExample: Test.User`nEnter",Mandatory = $true)]
    [string]$newUserName
    )
    if ($userDataPath.EndsWith("\")){
            $confirmedTerminatingUserPath = $userDataPath
        }
    else{
        $confirmedTerminatingUserPath = $userDataPath , "\" -join ""
    }
    if(!(Test-Path $confirmedTerminatingUserPath -ErrorAction SilentlyContinue)){Write-Warning "No User Directory Found, no rename has occured."}
    Else{
        $oldUserPath = $confirmedTerminatingUserPath , $previousName -join ""
        if(!(Test-Path $oldUserPath)){Write-Warning "Failed to find $oldUserPath, no rename has occured."}
        else{
            try{
                $newUserPath = $confirmedTerminatingUserPath , $newUserName -join ""
                Rename-Item -Path $userDataPath -NewName $newUserPath
                Write-Output "Verify $newUserName can access $newUserPath"
            }
            catch{
                Write-Warning "Failed to rename $oldUserPath to $newUserPath, perform manual troubleshooting."
            }
        }
    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




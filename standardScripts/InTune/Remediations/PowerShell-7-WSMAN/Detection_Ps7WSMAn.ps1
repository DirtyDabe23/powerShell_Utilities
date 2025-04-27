#Requires -version 7.0 
$psConfiguration = Get-PSSessionConfiguration -Name PowerShell.7

If(!($psConfiguration.enabled)){
    Write-Output "Needs Enabled"
    Exit 1 
}
Else{
    Write-Output "Enabled"
    Exit 0
}
# SIG # Begin signature block#Script Signature# SIG # End signature block





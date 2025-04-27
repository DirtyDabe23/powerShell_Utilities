$primaryEmail = Read-Host "Enter the Email Address you would like to use for the Shared Mailbox"
$officeLocation = Read-Host "Enter the Office Location that this account is going to be used for"
$sharedMailboxName = Read-Host "Enter the display name you would like to use"
$serviceAccount = "Service Account"
$companyName = "Not Affiliated"

New-Mailbox -Shared -PrimarySmtpAddress $primaryEmail -Name $sharedMailboxName -DisplayName $sharedMailboxName -Alias $sharedMailboxName.Replace(" ","")
$user = Get-MgBetaUser -search "Mail:$primaryEmail" -ConsistencyLevel Eventual -errorAction SilentlyContinue
while (!$user){
    Write-Output "Waiting on user to be created"
    Start-Sleep -Seconds 5
    $user = Get-MgBetaUser -search "Mail:$primaryEmail" -ConsistencyLevel Eventual -ErrorAction SilentlyContinue

    
}
Write-Output "Modifying User to be ComplteamMembert"
Update-MGBetaUser -UserId $user.ID -UserPrincipalName $primaryEmail -CompanyName $companyName -OfficeLocation $officeLocation -EmployeeType $serviceAccount -JobTitle $serviceAccount

# SIG # Begin signature block#Script Signature# SIG # End signature block





$userID = Read-Host "Enter the UPN of the user who needs 64 bit office apps"
Update-MGBetaUser -userid $userID -OnPremisesExtensionAttributes @{ExtensionAttribute3 = "64"}
SignatureBlock


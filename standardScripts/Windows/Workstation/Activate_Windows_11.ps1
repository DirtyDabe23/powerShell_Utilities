if((Get-CimInstance -ClassName SoftwareLicensingProduct | Where-Object {$_.name -match 'windows' -AND $_.PartialProductKey}).LicenseStatus -ne '1'){
    Write-Host "Activating Windows"
    slmgr /ipk (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
    slmgr /ato
}
# SIG # Begin signature block#Script Signature# SIG # End signature block





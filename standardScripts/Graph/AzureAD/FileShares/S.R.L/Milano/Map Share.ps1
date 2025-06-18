reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters /v CloudKerberosTicketRetrievalEnabled /t REG_DWORD /d 0

$keyPathLSA = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
Set-ItemProperty -Path $keyPathLSA -Name 'lmcompatibilitylevel' -Value '3' -Type 'DWord' -Force




$hostServer = $registeredServer.FriendlyName

$drives = Get-PSDrive
$hostServer = "PREFIX-VS-FS01"

If ($drives.Names -NotContains "T")
{
    Write-Output "Using T for the Drive Letter"
    New-PSDrive -Name "T" -PSProvider FileSystem -Root "\\$hostServer\GlobalFS" -Persist
}

ElseIf ($drives.Name -Contains "T" -and $drives.Names -NotContains "G")
{
    Write-Output "Using G for the Drive Letter"
    New-PSDrive -Name "G" -PSProvider FileSystem -Root "\\$hostServer\GlobalFS" -Persist
}

Elseif ($drives.Name -Contains "G")
{
    Write-Output "All Standard Drive Letters are in use."
    Write-Output "The following drive lettesr are in use: `n$($drives.name)"
    $driveLetter = Read-Host "Enter the Drive Letter that is not currently in use"
    New-PSDrive -Name "$driveLetter" -PSProvider FileSystem -Root "\\$hostServer\GlobalFS" -Persist

}

New-PSDrive -Name "T" -PSProvider FileSystem -Root "\\$hostServer\Global" -Persist
# SIG # Begin signature block#Script Signature# SIG # End signature block







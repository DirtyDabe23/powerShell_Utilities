$computers = Import-CSV -Path C:\Temp\LabComputers.csv 
$cred = Get-Credential

ForEach ($computer in $computers)
{
    Enter-PSSession -computername $computer.Name -credential $cred 
    gpupdate /force
    Exit-PSSession 
}
SignatureBlock


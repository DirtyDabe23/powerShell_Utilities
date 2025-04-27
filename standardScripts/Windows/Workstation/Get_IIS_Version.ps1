$computers = "PREFIX-LT-1114" , "PREFIX-LT-1240" , "PREFIX-LT-1181", "PREFIX-LT-1128" , "uniqueParentCompany-1037"
$results = @()
If (!($cred))
{
    Write-Output "Pending Credential Request"
    $cred = Get-Credential
}
ForEach ($computer in $computers){
$config = Invoke-Command -SCriptBlock {get-itemproperty HKLM:\SOFTWARE\Microsoft\InetStp\  | select setupstring,versionstring} -ComputerName $computer -Credential $cred -Authentication Negotiate
$results+=[PSCUstomOBject]@{
setupstring = $config.setupstring
versionString = $config.VersionString
computer = $config.PSComputerName}
}
# SIG # Begin signature block#Script Signature# SIG # End signature block







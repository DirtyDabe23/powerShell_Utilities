$computers = "Laptop-1114" , "Laptop-1240" , "Laptop-1181", "Laptop-1128" , "parentCompany-1037"
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
SignatureBlock


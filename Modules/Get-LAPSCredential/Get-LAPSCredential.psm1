function Get-LAPSCredential{
    <#
    .SYNOPSIS
    Retrieves the LAPS credential for a specified computer.
    .DESCRIPTION
    This function retrieves the LAPS (Local Administrator Password Solution) credential for a specified computer.
    It uses the Get-LapsAADPassword cmdlet to fetch the password and account information,
    and then tests the validity of the credentials by attempting to establish a WSMan session.
    .PARAMETER computerName
    The name of the computer for which to retrieve the LAPS credential.
    .EXAMPLE
    Get-LAPSCredential -computerName "Computer01"
    Retrieves the LAPS credential for the computer named "Computer01".
    .OUTPUTS
    PSCredential
    Returns a PSCredential object containing the LAPS account and password if valid, otherwise returns $null.
    .NOTES
    Requires the Get-LapsAADPassword cmdlet to be available in the session.
    .LINK
    https://docs.microsoft.com/en-us/powershell/module/laps/get-lapsaadpassword
    .
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,Position = 0, HelpMessage = "Enter the name of the computer to retrieve LAPS credentials for.")]
        [string]$computerName,
        [Parameter(Mandatory = $false, HelpMessage = "Use this switch to attempt to test the connection.")]
        [switch]$TestConnection,
        [Parameter(Mandatory = $false, HelpMessage = "Use this switch to force the use of PowerShell 7 for testing.")]
        [switch]$UsePS7,
        [Parameter(Mandatory = $false, HelpMessage = "Use this to return the LAPS User and Password in Plain Text.")]
        [switch]$asPlainText
    ) 
        $lapsData = Get-LapsAADPassword -DeviceIds "$computerName" -IncludePasswords  
        if($lapsData){
            $account  = ".\" , $($lapsData.account) -join ""
            $pw = $lapsData.password
            [PSCREDENTIAL]$LAPS = [PSCredential]::New($account,$pw)
        
            if ($TestConnection) {
                Write-Host "Testing LAPS Credential for $computerName..." -ForegroundColor Yellow
                $baseTestResult = Test-Wsman -ComputerName $computerName -Authentication Negotiate -Credential $LAPS
                $ps7TestResult = Test-PSSessionConfiguration -ComputerName $computerName -ConfigurationName "PowerShell.7" -Authentication Negotiate -Credential $LAPS
                if ($baseTestResult -and $ps7TestResult){
                    Write-Host "LAPS Credential for $computerName is valid" -ForegroundColor Green
                    return $LAPS
                }
                else{
                    throw "LAPS Credential for $computerName is not valid" 
                }
            }
            if ($asPlainText -eq $true){
                $lapsData = Get-LapsAADPassword -DeviceIds "$computerName" -IncludePasswords -AsPlainText
                return [PSCustomObject]@{
                    UserName = $account
                    Password = $lapsData.password
                }
            }
            else{      
                return $LAPS
            }
        }
        else{
            Throw "No LAPS data found for $computerName"
        }
}
SignatureBlock


<#
=============================================================================================
Name:           Get MFA Status Report
Description:    Gets MFA status for all users and authentication methods
Version:        1.0
Website:        activedirectorypro.com
Script by:      activedirectorypro.com
Instructions:   https://activedirectorypro.com/mfa-status-powershell
============================================================================================
#>

#Get all Azure users
$users = get-mguser -All

$results=@();
Write-Host  "`nRetreived $($users.Count) users";
#loop through each user account
foreach ($user in $users) {

Write-Host  "`n$($user.UserPrincipalName)";
$myObject = [PSCustomObject]@{
    user               = "-"
    MFAstatus          = "_"
    email              = "-"
    fido2              = "-"
    app                = "-"
    password           = "-"
    phone              = "-"
    softwareoath       = "-"
    tempaccess         = "-"
    hellobusiness      = "-"
}

$MFAData=Get-MgUserAuthenticationMethod -UserId $user.UserPrincipalName #-ErrorAction SilentlyContinue

$myobject.user = $user.UserPrincipalName;
    #check authentication methods for each user
    ForEach ($method in $MFAData) {
    
        Switch ($method.AdditionalProperties["@odata.type"]) {
          "#microsoft.graph.emailAuthenticationMethod"  { 
             $myObject.email = $true 
             $myObject.MFAstatus = "Enabled"
          } 
          "#microsoft.graph.fido2AuthenticationMethod"                   { 
            $myObject.fido2 = $true 
            $myObject.MFAstatus = "Enabled"
          }    
          "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod"  { 
            $myObject.app = $true 
            $myObject.MFAstatus = "Enabled"
          }    
          "#microsoft.graph.passwordAuthenticationMethod"                {              
                $myObject.password = $true 
                # When only the password is set, then MFA is disabled.
                if($myObject.MFAstatus -ne "Enabled")
                {
                    $myObject.MFAstatus = "Disabled"
                }                
           }     
           "#microsoft.graph.phoneAuthenticationMethod"  { 
            $myObject.phone = $true 
            $myObject.MFAstatus = "Enabled"
          }   
            "#microsoft.graph.softwareOathAuthenticationMethod"  { 
            $myObject.softwareoath = $true 
            $myObject.MFAstatus = "Enabled"
          }           
            "#microsoft.graph.temporaryAccessPassAuthenticationMethod"  { 
            $myObject.tempaccess = $true 
            $myObject.MFAstatus = "Enabled"
          }           
            "#microsoft.graph.windowsHelloForBusinessAuthenticationMethod"  { 
            $myObject.hellobusiness = $true 
            $myObject.MFAstatus = "Enabled"
          }                   
        }
    }

##Collecting objects
$results+= $myObject;

}
# Display the custom objects
$results
# SIG # Begin signature block#Script Signature# SIG # End signature block




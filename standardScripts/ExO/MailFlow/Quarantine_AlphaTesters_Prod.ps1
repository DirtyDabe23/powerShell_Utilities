    $StartTime = Get-Date 
    #THIS SCRIPT MUST BE RUN IN POWERSHELL 5.1, IT DOES NOT WORK IN POWERSHELL 7 FOR WHATEVER REASON

    #secureGraph
    #The Tenant ID from App Registrations
    $tenantId = $tenantIDString

    # Construct the authentication URL
    $uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
 
    #The Client ID from App Registrations
    $clientId = $appIDString
 

 
    #The Client ID from certificates and secrets section
    $clientSecret = 'GraphAPI'
 
 
    # Construct the body to be used in Invoke-WebRequest
    $body = @{
        client_id     = $clientId
        scope         = "https://graph.microsoft.com/.default"
        client_secret = $clientSecret
        grant_type    = "client_credentials"
    }
 
    # Get Authentication Token
    $tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing
 
    # Extract the Access Token
    $token = ($tokenRequest.Content | ConvertFrom-Json).access_token
    $secureToken = ConvertTo-SecureString -String $token -AsPlainText -Force
    #connect to graph
    Connect-MGGraph -AccessToken $secureToken


    #connect to Exchange Online
    $exoCertThumb = "FE63624C5EE7EF5F9CC0ABEFB0EA3CC9390DC904"
    $exoAppID = "1f97c81e-f222-4046-967a-5051db6f1ec1"
    $exoORG = "uniqueParentCompanyinc.onmicrosoft.com"
		
    Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG

    $users = @()
    $members = Get-MGGroupMember -GroupId "79957873-7b8a-46df-89ba-1c762b18c890"
    ForEach ($member in $members)
    {
        If (!(Get-MGBetaUser -userID $($member.ID) -erroraction SilentlyContinue)) 
        {
            $null
        }
        Else
        {
            $users += Get-MGBetaUser -userID $member.ID
        }
       
    }
    $users+= Get-MGBetaUser -UserId "Mike.Hilker@uniqueParentCompany.com"
    
    

    #Tracker / Performance Counter
    $max = $users.count 
    $counter = 1 

    ForEach ($user in $users)
    {
    Write-Host "User #$counter out of $max"

        Connect-MGGraph -AccessToken $secureToken -NoWelcome
		
        Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG


        $trustedQuarantine = @();
        $trustedQuarantineDB = @();
        $userUPN = $user.userprincipalname 
        $userQuarantines = Get-QuarantineMessage -RecipientAddress $userUPN -ReleaseStatus NotReleased
    
        ForEach ($userQuarantine in $userQuarantines)
        {
        $senderAddr = $userQuarantine.senderaddress.split('@')[1]
        #Domains via SQL DB
        
        $sqlcn = New-Object System.Data.SqlClient.SqlConnection
        $sqlcn.ConnectionString = "Server=PREFIX-sql-qa1\lob_qa;Integrated Security=true;Initial Catalog=DomainVerification"
        $sqlcn.Open()
        $sqlcmd=$sqlcn.CreateCommand()
        $query="select * from dbo.Domains WHERE Domain='$senderAddr'"
        $sqlcmd.CommandText = $query
        $adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd
        $data = New-Object System.Data.DataSet
        


        If ($adp.Fill($data) -eq '1' )
        {
            #close the connection to the email DB
            $sqlCN.close()
            #Email MessageID via SQL DB
            $sqlcn = New-Object System.Data.SqlClient.SqlConnection
            $sqlcn.ConnectionString = "Server=PREFIX-sql-qa1\lob_qa;Integrated Security=true;Initial Catalog=DomainVerification"
            $sqlcn.Open()
            $sqlcmd=$sqlcn.CreateCommand()
            $query="SELECT * FROM dbo.EmailData WHERE MessageID = '$($userquarantine.messageID)' AND RecipientAddress = '$($userQuarantine.recipientaddress)'"
            $sqlcmd.CommandText = $query
            $adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd
            $data = New-Object System.Data.DataSet
            $adp.Fill($data) | Out-Null

            
            If ($adp.Fill($data) -eq '0')
            {


            $trustedQuarantine +=[PSCustomObject]@{ 
            Received = $userQuarantine.receivedTime
            Sender = $userQuarantine.SenderAddress
            Subject = $userQuarantine.Subject
            }
        

            
            $serverName = "PREFIX-sql-qa1\lob_qa"
            $databaseName = "DomainVerification"
            $tableName = "dbo.EmailData"
            $Connection = New-Object System.Data.SQLClient.SQLConnection
            $Connection.ConnectionString = "server='$serverName';database='$databaseName';trusted_connection=true;"
            $Connection.Open()
            $Command = New-Object System.Data.SQLClient.SQLCommand
            $Command.Connection = $Connection
            
            $MessageID = $userQuarantine.MessageID
            $RecipientAddress = $userQuarantine.recipientaddress 
            $SenderAddress = $userQuarantine.SenderAddress
            $Subject = $userQuarantine.Subject.Replace("'", "''")
            $Received = $userQuarantine.receivedTime
            $Type = $userQuarantine.Type
            $Direction = $userquarantine.direction
            
            $insertquery="
            INSERT INTO $tableName
                ([MessageID],[RecipientAddress],[SenderAddress],[Subject],[ReceivedTime],[Type],[Direction])
            VALUES
                ('$MessageID','$RecipientAddress','$SenderAddress','$Subject','$Received','$Type','$Direction')"
            $Command.CommandText = $insertquery
            $Command.ExecuteNonQuery()
            $Connection.Close();
            $sqlcn.close()
            }
        
        
        Else
        {
        $null
        }
        }
        }

    if($trustedQuarantine.count -eq 0)
        {
        Write-Host "No Email to send"
        }

    Else 
    {
$Date = Get-Date -Format yyyy.MM.dd.HH.mm
$attachmentPath ="C:\Temp\"+ $Date+"."+$userUPN.split('@')[0]+".csv"

$trustedQuarantine | export-csv -path $attachmentPath
$emailBody = $trustedQuarantine | Out-String
# The path of the file attachment

# Convert the file to Base64
$attachmentContent = [System.Convert]::ToBase64String((Get-Content -Path $attachmentPath -Encoding Byte))

# JSON Payload Construction
$params = @{
    message = @{
        subject = "Quarantined Emails Matching Trusted Senders"
        body = @{
            contentType = "Text"
            content = "Please review the attachment for a list of quarantined emails from trusted senders. Emails can have their releases requested at https://security.microsoft.com/quarantine $emailBody"
        }
        toRecipients = @(
            @{
                emailAddress = @{
                    address = "$userUPN"
                }
            }
        )
        ccRecipients = @(
			@{
				emailAddress = @{
					address = "$userName@uniqueParentCompany.com"
				}
			}
		)
        attachments = @(
            @{
                "@odata.type" = "#microsoft.graph.fileAttachment"
                name = (Split-Path -Path $attachmentPath -Leaf)
                contentBytes = $attachmentContent
            }
        )
    }
    saveToSentItems = "true"
}
$userID = "3be04ec2-c2d1-4804-82ad-bf4c1afdaee8"

Write-Host "I would have sent an email here but we're just testing"
# A UPN can also be used as -UserId.
Send-MgUserMail -UserId $userID -BodyParameter $params
    }   
    $counter += 1        
    }
    $endTime = Get-Date 
    $Connection.Close();
    $sqlcn.close()
# SIG # Begin signature block#Script Signature# SIG # End signature block









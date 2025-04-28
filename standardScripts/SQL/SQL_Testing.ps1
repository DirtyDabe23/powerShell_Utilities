 #Pull just the messageID values from the DB    
    
    $sqlcn = New-Object System.Data.SqlClient.SqlConnection
    $sqlcn.ConnectionString = "Server=$sqlServerName\lob_qa;Integrated Security=true;Initial Catalog=DomainVerification"
    $sqlcn.Open()
    $sqlcmd=$sqlcn.CreateCommand()
    $query="select MessageID from dbo.EmailData"
    $sqlcmd.CommandText = $query
    $adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd
    $data = New-Object System.Data.DataSet
    $adp.Fill($data) | Out-Null
    $emaildb = $data.Tables
    $emailDB

    #To get a single messageID 


    $sqlcn = New-Object System.Data.SqlClient.SqlConnection
    $sqlcn.ConnectionString = "Server=$sqlServerName\lob_qa;Integrated Security=true;Initial Catalog=DomainVerification"
    $sqlcn.Open()
    $sqlcmd=$sqlcn.CreateCommand()
    $query="select MessageID from dbo.EmailData WHERE MessageID='adfa20'"
    $sqlcmd.CommandText = $query
    $adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd
    $data = New-Object System.Data.DataSet
    $adp.Fill($data) | Out-Null
    $emaildb = $data.Tables



    #To get all columns for the associated row:


    "SELECT * FROM dbo.EmailData WHERE MessageID = 'adfa20' AND RecipientAddress = $userEmail"

    $sqlcn = New-Object System.Data.SqlClient.SqlConnection
    $sqlcn.ConnectionString = "Server=$sqlServerName\lob_qa;Integrated Security=true;Initial Catalog=DomainVerification"
    $sqlcn.Open()
    $sqlcmd=$sqlcn.CreateCommand()
    $query="SELECT * FROM dbo.EmailData WHERE MessageID = 'adfa20' AND RecipientAddress = $userEmail"
    $sqlcmd.CommandText = $query
    $adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd
    $data = New-Object System.Data.DataSet
    $adp.Fill($data) | Out-Null
    $emaildb = $data.Tables

   



    $checkMsgID = 'adfa20'
    $checkRecip = "$userEmail"
    $sqlcn = New-Object System.Data.SqlClient.SqlConnection
    $sqlcn.ConnectionString = "Server=$sqlServerName\lob_qa;Integrated Security=true;Initial Catalog=DomainVerification"
    $sqlcn.Open()
    $sqlcmd=$sqlcn.CreateCommand()
    $query="SELECT * FROM dbo.EmailData WHERE MessageID = '$checkMsgID' AND RecipientAddress = '$checkRecip'"
    $sqlcmd.CommandText = $query
    $adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd
    $data = New-Object System.Data.DataSet
    $adp.Fill($data) | Out-Null




# Email DAta Insert Query
$serverName = "$sqlServerName\lob_qa"
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



#Domain Data Update Query
$domainUpdate = Invoke-SpfDkimDmarc -Name "yahoo.cn" -Server "1.1.1.1"

$serverName = "$sqlServerName\lob_qa"
$databaseName = "DomainVerification"
$tableName = "dbo.Domains"
$Connection = New-Object System.Data.SQLClient.SQLConnection
$Connection.ConnectionString = "server='$serverName';database='$databaseName';trusted_connection=true;"
$Connection.Open()
$Command = New-Object System.Data.SQLClient.SQLCommand
$Command.Connection = $Connection
            
$dbDomain = $domainUpdate.name
$dbSPFRecord = $domainUpdate.SPFRecord
$dbSPFAdvisory = $domainUpdate.SPFAdvisory
$dbSPFRecordLength = $domainUpdate.SPFRecordLenght
$dbDmarcRecord = $domainUpdate.DmarcRecord
$dbDmarcAdvisory = $domainUpdate.DmarcAdvisory
$dbDkimRecord = $domainUpdate.DkimRecord
$dbDkimSelector = $domainUpdate.DkimSelector
$dbDkimAdvisory = $domainUpdate.DkimAdvisory
            
$updateQuery = @"
UPDATE $tableName
SET
    [SpfRecord] = '$dbSPFRecord',
    [SpfAdvisory] = '$dbSPFAdvisory',
    [SpfRecordLength] = '$dbSPFRecordLength',
    [DmarcRecord] = '$dbDmarcRecord',
    [DmarcAdvisory] = '$dbDmarcAdvisory',
    [DkimRecord] = '$dbDkimRecord',
    [DkimSelector] = '$dbDkimSelector',
    [DkimAdvisory] = '$dbDkimAdvisory'
WHERE
    [Domain] = '$dbDomain'
"@
  $Command.CommandText = $updateQuery
  $Command.ExecuteNonQuery()
  $Connection.Close();

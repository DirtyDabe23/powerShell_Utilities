$sqlcn = New-Object System.Data.SqlClient.SqlConnection
$sqlcn.ConnectionString = "Server=PREFIX-sql-qa1\lob_qa;Integrated Security=true;Initial Catalog=DomainVerification"
$sqlcn.Open()
$sqlcmd=$sqlcn.CreateCommand()
$query="select * from dbo.Domains"
$sqlcmd.CommandText = $query
$adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd
$data = New-Object System.Data.DataSet
$adp.Fill($data) | Out-Null
$data.Tables
$domains = $data.Tables


$sqlcn = New-Object System.Data.SqlClient.SqlConnection
$sqlcn.ConnectionString = "Server=PREFIX-sql-qa1\lob_qa;Integrated Security=true;Initial Catalog=DomainVerification"
$sqlcn.Open()
$sqlcmd=$sqlcn.CreateCommand()
$query="select * from dbo.EmailData"
$sqlcmd.CommandText = $query
$adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd
$data = New-Object System.Data.DataSet
$adp.Fill($data) | Out-Null
$data.Tables
$emailData = $data.Tables


#set location to the following
Set-Location "SQLSERVER:\SQL\PREFIX-SQL-QA1\LOB_QA\Databases\DomainVerification\Tables\dbo.EmailData"


#read DB data
Read-SqlTableData -ServerInstance "PREFIX-SQL-QA1\LOB_QA" -DatabaseName "DomainVerification" -SchemaName "dbo" -TableName "domains"


$trustedQuarantineDB | Write-SqlTableData -ServerInstance "PREFIX-SQL-QA1\LOB_QA" -DatabaseName "DomainVerification" -SchemaName "dbo" -TableName "domains"




Write-SqlTableData -ServerInstance "PREFIX-SQL-QA1\LOB_QA" -DatabaseName "DomainVerification" -SchemaName "dbo" -TableName "EmailData" -InputData @{'[MessageId]' = $($trustedQuarantineDB.messageID); '[RecipientAddress]' = $($trustedQuarantineDB.recipientaddress); '[SenderAddress]' =$($trustedQuarantineDB.sender); '[Subject]' = $($trustedQuarantineDB.subject); '[ReceivedTime]' = $($trustedQuarantineDB.received); '[Type]' = $($trustedQuarantineDB.type); '[Direction]' = $($trustedQuarantineDB.direction);  } -PassThru


Write-SqlTableData -ServerInstance "PREFIX-SQL-QA1\LOB_QA" -DatabaseName "DomainVerification" -SchemaName "dbo" -TableName "EmailData" -InputData @{ MessageID = $($trustedQuarantineDB.messageID); RecipientAddress = $($trustedQuarantineDB.recipientaddress); SenderAddress =$($trustedQuarantineDB.sender); Subject = $($trustedQuarantineDB.subject); ReceivedTime = $($trustedQuarantineDB.received); Type = $($trustedQuarantineDB.type); Direction = $($trustedQuarantineDB.direction);  } -PassThru

Write-SqlTableData -ServerInstance "PREFIX-SQL-QA1\LOB_QA" -DatabaseName "DomainVerification" -SchemaName "dbo" -TableName "EmailData" -InputData @{ [MessageID] = ($trustedQuarantineDB.messageID); [RecipientAddress] = $($trustedQuarantineDB.recipientaddress); [SenderAddress] =$($trustedQuarantineDB.sender); [Subject] = $($trustedQuarantineDB.subject); [ReceivedTime] = $($trustedQuarantineDB.received); Type = $($trustedQuarantineDB.type); [Direction] = $($trustedQuarantineDB.direction);  } -PassThru


Write-SqlTableData -ServerInstance "PREFIX-SQL-QA1\LOB_QA" -DatabaseName "DomainVerification" -SchemaName "dbo" -TableName "EmailData" -InputData @{'MessageID' = $trustedQuarantineDB.messageID; 'RecipientAddress' = $trustedQuarantineDB.recipientaddress; 'SenderAddress' =$trustedQuarantineDB.sender; 'Subject' = $trustedQuarantineDB.subject; 'ReceivedTime' = $trustedQuarantineDB.received; 'Type' = $trustedQuarantineDB.type; 'Direction' = $trustedQuarantineDB.direction;  } -PassThru


Write-SqlTableData -ServerInstance "PREFIX-SQL-QA1\LOB_QA" -DatabaseName "DomainVerification" -SchemaName "dbo" -TableName "EmailData" -InputData @{'MessageID' = $messageID; 'RecipientAddress' = $RecipientAddress; 'SenderAddress' =$Sender; 'Subject' = $subject; 'ReceivedTime' = $received; 'Type' = $type; 'Direction' = $direction;  } -PassThru

#SQL Stuff to review DB stuff
<#

SELECT TOP (1000) [Id]
      ,[MessageId]
      ,[RecipientAddress]
      ,[SenderAddress]
      ,[Subject]
      ,[ReceivedTime]
      ,[Type]
      ,[Direction]
  FROM [DomainVerification].[dbo].[EmailData]

#>

$payload = @{
'[MessageId]' = $userQuarantine.MessageID
'[RecipientAddress]' = $userQuarantine.recipientaddress[0].tostring()
'[SenderAddress]' = $userQuarantine.SenderAddress
'[Subject]' = $userQuarantine.Subject
'[ReceivedTime]' = $userQuarantine.receivedTime
'[Type]' = $userQuarantine.Type
'[Direction]' = $userquarantine.direction
}



$payload = New-Object System.Data.DataTable
 
$col1 = New-Object System.Data.DataColumn("messageID")
$col2 = New-Object System.Data.DataColumn("RecipientAddress")
$col3 = New-Object System.Data.DataColumn("SenderAddress")
$col4 = New-Object System.Data.DataColumn("Subject")
$col5 = New-Object System.Data.DataColumn("ReceivedTime",[datetime])
$col6 = New-Object System.Data.DataColumn("Type")
$col7 = New-Object System.Data.DataColumn("Direction")
 
$payload.Columns.Add($col1)
$payload.Columns.Add($col2)
$payload.Columns.Add($col3)
$payload.Columns.Add($col4)
$payload.Columns.Add($col5)
$payload.Columns.Add($col6)
$payload.Columns.Add($col7)
 
$row = $payload.NewRow()
 
$row["messageID"] = $userQuarantine.MessageID
$row["RecipientAddress"] = $userQuarantine.recipientaddress[0].tostring()
$row["SenderAddress"] = $userQuarantine.SenderAddress
$row["Subject"] = $userQuarantine.Subject
$row["ReceivedTime"] = $userQuarantine.receivedTime
$row["Type"] = $userQuarantine.Type
$row["Direction"] = $userquarantine.direction
 
$payload.Rows.Add($row)




########SQL Command from : https://www.c-sharpcorner.com/blogs/insert-data-into-sql-server-table-using-powershell

# SIG # Begin signature block#Script Signature# SIG # End signature block





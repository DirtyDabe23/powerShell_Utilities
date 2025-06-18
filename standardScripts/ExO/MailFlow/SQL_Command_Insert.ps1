$serverName = "PREFIX-sql-qa1\lob_qa"
$databaseName = "DomainVerification"
$tableName = "dbo.EmailData"
$studentName = 'John','Debo','Carry','Mini'
$standard = '5'
$Connection = New-Object System.Data.SQLClient.SQLConnection
$Connection.ConnectionString = "server='$serverName';database='$databaseName';trusted_connection=true;"
$Connection.Open()
$Command = New-Object System.Data.SQLClient.SQLCommand
$Command.Connection = $Connection
foreach($Name in $studentName){
  $insertquery="
  INSERT INTO $tableName
      ([MessageID],[RecipientAddress],[SenderAddress],[Subject],[ReceivedTime],[Type],[Direction])
    VALUES
      ('$MessageID','$RecipientAddress','$SenderAddress','$subject','$ReceivedTime','$Type','$direction')"
  $Command.CommandText = $insertquery
  $Command.ExecuteNonQuery()
}
$Connection.Close();
# SIG # Begin signature block#Script Signature# SIG # End signature block





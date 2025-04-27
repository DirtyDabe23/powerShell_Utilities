$sqlcn = New-Object System.Data.SqlClient.SqlConnection
$sqlcn.ConnectionString = "Server=PREFIX-sql-qa1\lob_qa;Integrated Security=true;Initial Catalog=DomainVerification"
$sqlcn.Open()
$sqlcmd=$sqlcn.CreateCommand()
$query="select * from dbo.Domains"
$sqlcmd.CommandText = $query
$adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd
$data = New-Object System.Data.DataSet
$adp.Fill($data) | Out-Null
$domains = $data.Tables
$sqlcn.close()


ForEach ($domain in $domains.domain)
{
$domainUpdate = Invoke-SpfDkimDmarc -Name $domain -Server "1.1.1.1"

$serverName = "PREFIX-sql-qa1\lob_qa"
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
}
# SIG # Begin signature block#Script Signature# SIG # End signature block





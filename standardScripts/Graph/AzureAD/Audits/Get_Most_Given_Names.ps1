$allAADUsers = Get-MGBetaUser -All -ConsistencyLevel eventual | Where-Object {($_.UserType -eq "member")}
$givenNames = $allAADUsers | Sort-Object -Property GivenName -Unique | Select-Object -Property GivenName

$givenNameCounts = @()

ForEach ($givenName in $givenNames)
{
   #strip the Office Location value down to the base element
   $gName = $givenName.GivenName
   #Get the user count for the individual Given Name  
   $gNameCount = ($allAADUsers | Where-Object {($_.GivenName -eq $gName)}).count
   #Add it into the PSCustomObject 
   $givenNameCounts += [PSCustomObject]@{
        GivenName       = $gName 
        GivenNameCount = $gNameCount
        }
     

}
# SIG # Begin signature block#Script Signature# SIG # End signature block





$members = Get-MgBetaUser | Get-Member 
$properties = $members | Where-Object {($_.MemberType -eq 'Property')}
$self = Get-MGBetaUser -userid "david.drosdick@Domain.extension1" -select *

$selfInfoFull = @()

ForEach ($property in $properties.name)
{
    Write-Output "$Property"
    $propertyValue = $self | Select-Object -Property $property -ExpandProperty $property 

    $selfInfoFull.add([PSCustomObject]@{
        $property = $propertyValue
    })

}

SignatureBlock


$members = Get-MgBetaUser | Get-Member 
$properties = $members | Where-Object {($_.MemberType -eq 'Property')}
$self = Get-MGBetaUser -userid "$userName@uniqueParentCompany.com" -select *

$selfInfoFull = @()

ForEach ($property in $properties.name)
{
    Write-Output "$Property"
    $propertyValue = $self | Select-Object -Property $property -ExpandProperty $property 

    $selfInfoFull.add([PSCustomObject]@{
        $property = $propertyValue
    })

}

# SIG # Begin signature block#Script Signature# SIG # End signature block






$text = "uniqueParentCompany-0830"
$separator = "-" # you can put many separator like this "; : ,"

$parts = $text.split($separator)

echo $parts[0] # return test.txt
echo $parts[1] # return the part after the separator

$type = (Get-ComputerInfo).CsPCSystemType

If ($type -eq "Mobile")
{
    $name = "PREFIX-LT-"+$parts[1]
}
Else
{
    $name = "PREFIX-DT-"+$parts[1]
}   
# SIG # Begin signature block#Script Signature# SIG # End signature block






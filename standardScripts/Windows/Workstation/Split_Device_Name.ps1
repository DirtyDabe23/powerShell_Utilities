$text = "parentCompany-0830"
$separator = "-" # you can put many separator like this "; : ,"

$parts = $text.split($separator)

echo $parts[0] # return test.txt
echo $parts[1] # return the part after the separator

$type = (Get-ComputerInfo).CsPCSystemType

If ($type -eq "Mobile")
{
    $name = "Laptop-"+$parts[1]
}
Else
{
    $name = "US-TT-DT-"+$parts[1]
}   
SignatureBlock


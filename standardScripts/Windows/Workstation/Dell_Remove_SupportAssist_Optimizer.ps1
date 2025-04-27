$badDells = Get-CimInstance -class Win32_product | where-object {($_.name -like 'Dell SupportAssist*') -or ($_.Name -like 'Dell Optimizer')}

If ($BadDells -eq $null -OR $badDells -eq " " -OR $baddells -eq "" -or $baddells.count -eq 0)
{
    $null
}

Else{

Write-Output "Programs found: `n$badDells"


ForEach ($badDellProgram in $badDells.name)
{
    Get-CimInstance -Class Win32_Product -Filter "Name = '$badDellProgram'" | Invoke-CimMethod -Name Uninstall -verbose
}

}
# SIG # Begin signature block#Script Signature# SIG # End signature block





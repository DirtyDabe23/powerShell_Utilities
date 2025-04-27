$badDells = Get-CimInstance -class Win32_product | where-object {($_.name -like 'Dell SupportAssist*') -or ($_.Name -like 'Dell Optimizer')}

ForEach ($badDellProgram in $badDells.name)
{
    Get-CimInstance -Class Win32_Product -Filter "Name = '$badDellProgram'" | Invoke-CimMethod -Name Uninstall
}
# SIG # Begin signature block#Script Signature# SIG # End signature block





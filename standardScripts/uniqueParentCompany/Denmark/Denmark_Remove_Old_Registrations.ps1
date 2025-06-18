$items = @()
$items = "HKLM:\SOFTWARE\Microsoft\Enrollments\$guid",`
"HKLM:\SOFTWARE\Microsoft\Enrollments\Status\$guid",`
"HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$guid" ,`
"HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled\$guid",`
"HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers\$guid",`
"HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\$guid",`
"HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger\$guid",`
"HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions\$guid"


ForEach ($item in $items)
{
    If (test-path $item)
    {
    Get-ITem -Path $item | Remove-Item -Force -Recurse
    }
}

# SIG # Begin signature block#Script Signature# SIG # End signature block




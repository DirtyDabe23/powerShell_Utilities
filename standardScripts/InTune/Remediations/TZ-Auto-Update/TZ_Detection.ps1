$Key = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate"
If($Key.GetValue("Start") -ne '3'   ) 	
	{
		exit 1
	}
else 
	{
		exit 0 
	}
# SIG # Begin signature block#Script Signature# SIG # End signature block






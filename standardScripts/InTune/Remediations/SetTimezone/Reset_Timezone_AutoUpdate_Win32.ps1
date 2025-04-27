$Key = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate"
If($Key.GetValue("Start") -ne '4'   ) 	
	{
		Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate -Name Start -Value “4” -Type DWord -Force 
        Set-Service -Name tzautoupdate -StartupType Automatic
		Start-Service tzautoupdate
	}
else 
	{
		Write-Host "all good"
        Set-Service -Name tzautoupdate -StartupType Automatic
		Start-Service tzautoupdate
	}
# SIG # Begin signature block#Script Signature# SIG # End signature block





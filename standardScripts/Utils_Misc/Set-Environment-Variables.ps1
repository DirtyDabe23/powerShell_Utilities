# Set a user-level environment variable
[Environment]::SetEnvironmentVariable("MyVariable", "MyValue", "User") 

# Set a system-level environment variable (requires admin privileges)
[Environment]::SetEnvironmentVariable("MyVariable", "MyValue", "Machine") 

#Retrieves all of the Machine-Wide Environmental Variables
Write-Host "Machine environment variables"
[Environment]::GetEnvironmentVariables("Machine")

#Retrieves all of the User Envrionmental Variables
Write-Host "User environment variables"
[Environment]::GetEnvironmentVariables("User")

# SIG # Begin signature block#Script Signature# SIG # End signature block




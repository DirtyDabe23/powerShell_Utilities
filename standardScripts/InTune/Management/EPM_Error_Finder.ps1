CD 'C:\Program Files\Microsoft EPM Agent\Logs\'
Get-ChildItem -Path ".\" -Recurse | Select-String -Pattern 'error'


'#
Get-Policies: Retrieves a list of all policies received by the Epm Agent for a given PolicyType (ElevationRules, ClientSettings).
Get-DeclaredConfiguration: Retrieves a list of WinDC documents that identify the policies targeted to the device.
Get-DeclaredConfigurationAnalysis: Retrieves a list of WinDC documents of type MSFTPolicies and checks if the policy is already present in Epm Agent (Processed column).
Get-ElevationRules: Query the EpmAgent lookup functionality and retrieves rules given lookup and target. Lookup is supported for FileName and CertificatePayload.
Get-ClientSettings: Process all existing client settings policies to display the effective client settings used by the EPM Agent.
Get-FileAttributes: Retrieves File Attributes for a .exe file and extracts its Publisher and CA certificates to a set location that can be used to populate Elevation Rule Properties for a particular application.
#' 
Import-Module 'C:\Program Files\Microsoft EPM Agent\EpmTools\EpmCmdlets.dll'
# SIG # Begin signature block#Script Signature# SIG # End signature block




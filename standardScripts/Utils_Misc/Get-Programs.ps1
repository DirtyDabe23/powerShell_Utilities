$programs = Get-WMIObject -Class Win32_Product
$programs | select vendor , name , caption , version , identifyingnumber | sort -Property @{Expression='Vendor'} , @{Expression='Name'} | ft
# SIG # Begin signature block#Script Signature# SIG # End signature block




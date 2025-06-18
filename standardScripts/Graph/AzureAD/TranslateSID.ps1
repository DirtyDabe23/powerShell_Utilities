$SID = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-21-1757981266-706699826-725345543-4138"
$User = $SID.Translate([System.Security.Principal.NTAccount])
$User.Value 
# SIG # Begin signature block#Script Signature# SIG # End signature block





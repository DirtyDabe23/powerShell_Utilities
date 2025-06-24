$userName = "GIT-Admin"
$userexist = (Get-LocalUser).Name -Contains $userName
if($userexist -eq $false) {
  try{ 
     New-LocalUser -Name $username -Description "GIT-Admin local user account" -NoPassword
     Exit 0
   }   
  Catch {
     Write-error $_
     Exit 1
   }
} 
SignatureBlock


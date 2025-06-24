$userName = "GIT-Admin"
$Userexist = (Get-LocalUser).Name -Contains $userName
if ($userexist) { 
  Write-Host "$userName exist" 
  Exit 0
} 
Else {
  Write-Host "$userName does not Exists"
  Exit 1
}
SignatureBlock


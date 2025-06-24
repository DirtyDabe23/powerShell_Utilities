$tempDirectory = "C:\Temp\"
if (test-path $tempDirectory) { 
  Write-Host "$tempDirectory exists" 
  Exit 0
} 
Else {
  Write-Host "$tempDirectory does not Exists"
  Exit 1
}
SignatureBlock


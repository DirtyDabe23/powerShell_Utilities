New-PSDrive -name "JobScope" -PSProvider "FileSystem" -root "\\subsidiaryCompany2-FP01\public\Operations & Office Instructions\Jobscope\24.4\Official Jobscope Enterprise (24.04.0)\Installs\Client"
Start-Process -FilePath "\\subsidiaryCompany2-FP01\public\Operations & Office Instructions\Jobscope\24.4\Official Jobscope Enterprise (24.04.0)\Installs\Client\Jobscope.msi" -argumentlist "/qn" 
SignatureBlock


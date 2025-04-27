$psModulePath       = "C:\Program Files\PowerShell\Modules\"
$moduleName         = "Setup-Dev"
$extensions         = ".ps1",".psm1"
$modulePath         = $psModulePath , $moduleName -join ""

$baseURI            = "https://raw.githubusercontent.com"
$userRepo           = "/DirtyDabe23"
$repoName           = "/DDrosdick_Public_Repo"
$baseEnd            = "/refs/heads"
$branch             = "/main"
$finalURIEnd        = "/setup_Dev.ps1"

If (!(Test-Path -Path $modulePath)){
    Write-Output "Creating: $modulePath"
    New-Item -Path $modulePath -ItemType Directory
    }
Else{
    Write-Output "$modulePath already exists"
}


$requestURI         = $baseURI , $userRepo , $repoName ,  $baseEnd , $branch , $finalURIEnd -join ""

$scriptFile         = $moduleName , $extensions[0] -join ""
$scriptFilePath     = $modulePath , $scriptFile -join "\"
$moduleFile         = $moduleName , $extensions[1] -join ""
$moduleFilePath     = $modulePath , $moduleFile -join "\"

$response           = invoke-webRequest -uri $requestURI

$response.content | Out-File -FilePath $scriptFilePath
Copy-Item -Path $scriptFilePath -Destination $moduleFilePath
# SIG # Begin signature block#Script Signature# SIG # End signature block




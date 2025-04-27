$Module = "BurntToast"
$scope = "AllUsers"
$version = "0.8.5"
if(Get-PSResource -Name $Module  -Scope $scope -Version $version -ErrorAction Stop){
        Get-PSResource -Name $Module  -Scope AllUsers -Version 0.8.5 | Write-Output 
        Exit 0
}
else{
    Install-PSResource -Name BurntToast -Version 0.8.5 -Scope AllUsers
    $Module = "BurntToast"
    $scope = "AllUsers"
    $version = "0.8.5"
    if(Get-PSResource -Name $Module  -Scope $scope -Version $version -ErrorAction Stop){
            Get-PSResource -Name $Module  -Scope AllUsers -Version 0.8.5 | Write-Output 
            Exit 0
    }
    else{
        Write-Output "Failed to Find $Module with Scope $Scope at Version $version after attempting installation"
        exit 1
    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block






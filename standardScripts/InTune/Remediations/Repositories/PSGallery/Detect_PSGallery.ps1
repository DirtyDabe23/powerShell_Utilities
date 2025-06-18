$repositoryName = "PSGallery"
if(Get-PSRepository -Name $repositoryName){
    $trustSetting = (Get-PSRepository -Name $repositoryName).InstallationPolicy
    if ($trustSetting -ne 'Trusted'){
        Write-Output "$repositoryName is $trustSetting."
        Exit 1  
    }
    else{
        Write-Output "Already Trusted"
        Exit 0
    }

}
else{
    Write-Output "Failed to Find Gallery"
    Exit 1
}

# SIG # Begin signature block#Script Signature# SIG # End signature block





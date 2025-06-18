$repositoryName = "PSGallery"
if(Get-PSRepository -Name $repositoryName){
    $trustSetting = (Get-PSRepository -Name $repositoryName).InstallationPolicy
    if ($trustSetting -ne 'Trusted'){
        Write-Output "$repositoryName is $trustSetting"
        Set-PSRepository -Name $repositoryName -InstallationPolicy Trusted
        $trustSetting = (Get-PSRepository -Name $repositoryName).InstallationPolicy
        if ($trustSetting -ne 'Trusted'){
            Write-Output "Failed to Apply"
            Exit 1
        }
    }
    else{
        Write-Output "$repositoryName is now $trustSetting"
        Exit 0
    }
}
else{
    Write-Output "Failed to Find Gallery"
    Exit 1
}

# SIG # Begin signature block#Script Signature# SIG # End signature block





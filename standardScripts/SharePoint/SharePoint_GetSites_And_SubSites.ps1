Param(
    $TenantUrl = "https://devmodernworkplace-admin.sharepoint.com/",
    $CredentialPath = $null,
    $DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop),
    $ExportPath = $DesktopPath + "\SitesExport.csv"
)
Function Export-CredentialFile 
{
    param(
    $Username,
    $Path
    )
    While ($Username -eq "" -or $null -eq $Username)
    {
        $Username = Read-Host "Please enter your username (john.doe@domain.de)"
    }
    
    While ($Path -eq ""-or $null -eq $Path)
    {
        $Path = Read-Host "Where should the credentials be exported to?"
    }
    $ParentPath = Split-Path $Path
    If ((Test-Path $ParentPath) -eq $false)
    {
        New-Item -ItemType Directory -Path $ParentPath
    }
    $Credential = Get-Credential($Username)
    $Credential | Export-Clixml -Path $Path
    Return $Credential
}
Function Import-CredentialFile ($Path)
{
    if (! (Test-Path $Path))
    {
        Write-Host "Could not find the credential object at $Path. Please export your credentials first"
    }
    else
    {
        Import-Clixml -Path $Path
    }
}
$Credential = Import-CredentialFile -Path $CredentialPath 
If ($Credential -eq $null)
{
    $Username = Read-Host "Please enter your username (john.doe@domain.de)"
    Export-CredentialFile -Path $CredentialPath -Username $Username
    $Credential = Import-CredentialFile $CredentialPath
}
#Connect to tenant
Connect-PnPOnline -Url $TenantUrl -Credentials $Credential
$Export = New-Object System.Collections.Generic.List[object]
$Sites = Get-PnPTenantSite
$SitesCount = $Sites.Count
$i= 1
foreach ($Site in $Sites)
{
    Write-Host "($i / $SitesCount) Processing site $($Site.Url)"
    Disconnect-PnPOnline
    Connect-PnPOnline -Url $Site.Url -Credentials $Credential
    $Site = Get-PnPSite
    
    #get the information of the root
    $NewExport = New-Object PsObject -Property @{
    
            Url = $Site.URl
            SubSitesCount = (Get-PnPSubWebs -Recurse).count
            ParentWeb = $null
    }
    $Export.Add($NewExport)
    #get the information of subwebs
    Get-PnPSubWebs -Recurse  -Includes ParentWeb| ForEach-Object {
        $NewExport = New-Object PsObject -Property @{
    
            Url = $_.URl
            SubSitesCount = $_.Webs.count
            ParentWeb = $_.ParentWeb.ServerRelativeUrl
        }
        $Export.Add($NewExport)
    }
    $i++
}
$Export | Export-Csv -Path $ExportPath -NoTypeInformation -Delimiter ";" -Force
# SIG # Begin signature block#Script Signature# SIG # End signature block




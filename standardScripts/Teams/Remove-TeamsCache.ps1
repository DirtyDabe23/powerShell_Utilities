function Remove-TeamsCache {
    <#
        .SYNOPSIS
            Remove Teams Cache
        .DESCRIPTION
            This script removes the Teams cache files.
        .NOTES
        #>
    Get-Process -Name "Ms-Teams" | Stop-Process -Force
    Write-Output "Waiting for Ms-Teams to close..."
    while (Get-Process -Name "Ms-Teams" -ErrorAction SilentlyContinue){
        Start-Sleep -Seconds 5
    }
    $startingLocation = Get-Location
    Set-Location "$env:UserPRofile\appdata\local\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams"
    $removedFiles = remove-item -path .\* -Force -Recurse
    Start-Process "Ms-Teams"
    Set-Location $startingLocation
    return $removedFiles
}
SignatureBlock


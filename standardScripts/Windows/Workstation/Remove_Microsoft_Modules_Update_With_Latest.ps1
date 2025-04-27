"$env:ProgramFiles\WindowsPowerShell\Modules" , "$env:ProgramFiles\PowerShell\Modules" | % {
Set-Location $_ 

$modules = Get-ChildItem -Path ".\"

ForEach ($module in $modules)
{
    $startingLocation = Get-Location
     Set-Location .\$($module.name)
     $items = Get-Item -path .\*
     if ($items.count -ge 2)
     {
     $items = $items | Sort-Object -Property Name -Descending
     $newest = $items[0]
     $items | Where-Object {($_.name -NE $newest.name)} | remove-item -force -Recurse 
     }
     Set-Location $startingLocation
}

$modules = Get-Module -listavailable
$MSMOdules = $modules | Where-Object {($_.Author -eq "Microsoft Corporation" -and ($_.RepositorySourceLocation -ne $null))}
$msModules | Export-CSv -Path "C:\Temp\BackupModules.csv" -Force

ForEach ($module in $MsModules){
    $startingLocation = Get-Location
    set-location $module.modulebase 
    Set-Location ..\
    $currentLocation = Get-Location 
    Set-Location ..\
    Remove-Item -Path $currentLocation -Recurse -Force
    set-location $startingLocation
}

ForEach ($module in $msModules)
{
    Install-PSResource -Name $module.Name -Scope AllUsers -Verbose
}
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




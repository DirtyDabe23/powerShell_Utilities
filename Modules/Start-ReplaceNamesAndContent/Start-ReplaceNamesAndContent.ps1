# Function to handle replacements
function Start-ReplaceNamesAndContent {
    <#
    .SYNOPSIS
    This will review all files and their contents for matching a string, and then will replace the value with a new one.
    
    .DESCRIPTION
    This will review all files and their contents for matching a string, and then will replace the value with a new one. By and large this can be used for the following things:
    Removing API Keys / PII / Sensitive Data
    Changing Variables
    
    
    .PARAMETER rootPath
    The path of which to inspect all files. It defaults to your current working directory, which can be evaluated using Get-Location in PWSH or pwd on UNIX systems.
    
    .PARAMETER removalStringValue
    Enter the value that should be removed. For example -removalStringValue 'John Wilson' will look for any files with the name 'John Wilson' or if they have contents that match 'John Wilson'
    It is case insensitive.
    
    .PARAMETER replacementStringValue
    Enter the value that will be entered as the replacement. Examples:
    -replacementStringValue 'John Wilson'
    #The Below will use the VALUE stored in $userName, ergo, if $userName -eq 'Ron Wilson' it will interpet that as 'Ron Wilson' 
    -replacementStringValue $userName 
    #The Below will inject the VARIABLE $userName itself into the filename and the file contents, where applicable.
    -replacementStringValue '$userName'
    
    .PARAMETER valueType
    The value type, useful for reporting when you are doing this operation at scale and need to categorize the operation(s).
    
    .EXAMPLE
    #The following reviews all files names and contents for 'asldf23lkrewrlzx34530ae3', replaces it with '$apiKey' and sets the valueType of the operation as APIKey. At it's conclusion it reports all files modified.
    Start-ReplaceNameAndContent -rootPath "C:\tempRepo" -removalStringValue "asldf23lkrewrlzx34530ae3" -replacementStringValue '$apiKey' -valueType 'APIKey'
    
    .NOTES
    You must exercise extreme caution that you do not rename your userDrive. A Future Version will remove that as a possibility.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, HelpMessage = "Enter the root path.`nExample: C:\tempRepo")]
        [string]$rootPath = $pwd,
        [Parameter(Position = 1,HelpMessage = "Enter the value to replace.`nExample:'asldf23lkrewrlzx34530ae3'",ParameterSetName = "Ad-Hoc",Mandatory = $true)]
        [string]$removalStringValue,
        [Parameter(Position = 2,HelpMessage = "Enter the value to replace the previous value WITH`nExample:'`$apiKey'",ParameterSetName = "Ad-Hoc",Mandatory = $true)]
        [string]$replacementStringValue,
        [Parameter(Position = 3, HelpMessage = "Enter the valueType that you are replacing.`nExample: 'API Keys'",ParameterSetName = "Ad-Hoc", Mandatory = $true)]
        [string]$valueType,
        [Parameter(Position = 4, HelpMessage = "Use this switch to use a JSON file",ParameterSetName = "JSON", Mandatory = $true)]
        [switch]$jsonFile,
        [Parameter(position = 5, HelpMessage = "Enter the Path to the JSON File",ParameterSetName = "JSON",Mandatory = $true)]
        [string]$jsonFilePath
    )
    switch ($jsonFile) {
        $true { 
            $replacements = Get-Content -Path $jsonFilePath | ConvertFrom-JSON 
        }
        Default {  
                $replacements = [PSCustomObject]@{                                           
                Pattern = $removalStringValue
                ReplacementValue = $ReplacementValue
            }
        }
    }
  
    # Gather all items recursively
    $files = Get-ChildItem -Path $rootPath -Recurse -Force

    # Sort items deepest path first (safe for renaming folders)
    $files = $files | Sort-Object { $_.FullName.Split('\').Count } -Descending

    $filesModified = @()

    foreach ($replacement in $replacements) {
        $pattern = $replacement.Pattern
        $replacementValue = $replacement.ReplacementValue

        foreach ($item in $files) {
            # Replace in file contents
            if (-not $item.PSIsContainer) {
                $content = Get-Content -Path $item.FullName -Raw
                if ($content -match [regex]::Escape($pattern)) {
                    $content -replace [regex]::Escape($pattern), $replacementValue | Set-Content -Path $item.FullName -Force
                    $filesModified += [PSCustomObject]@{
                        File        = $item.FullName
                        FileNewName = "N/A"
                        operation   = "File Content Replacement"
                        valueType   = $valueType
                    }
                }
            }

            # Replace in names
            if ($item.Name -match [regex]::Escape($pattern)) {
                $newName = $item.Name -replace [regex]::Escape($pattern), $replacementValue
                if (-not $item.PSIsContainer){
                $newFullPath = Join-Path -Path $item.DirectoryName -ChildPath $newName -ErrorAction SilentlyContinue
                }
                Rename-Item -LiteralPath $item.FullName -NewName $newName

                $filesModified += [PSCustomObject]@{
                    File        = $item.FullName
                    FileNewName = $newName
                    operation   = $item.PSIsContainer ? "Folder Name Replacement" : "File Name Replacement"
                    valueType   = $valueType
                }

                # Refresh the reference
                $item = Get-Item -LiteralPath $newFullPath -ErrorAction SilentlyContinue
            }
        }
    }
    return $filesModified
}

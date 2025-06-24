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

    .PARAMETER json
    This switch indiciates that you are using JSON  to pull the data.

    .PARAMETER jsonFilePath
    The Path to the .JSON file.  It must be [{Pattern:Value,ReplacementValue:Value,ValueType:Value},{Pattern:Value,ReplacementValue:Value,ValueType:Value},{Pattern:Value,ReplacementValue:Value,ValueType:Value}]
    
    
    .EXAMPLE
    #The following reviews all files names and contents for 'asldf23lkrewrlzx34530ae3', replaces it with '$apiKey' and sets the valueType of the operation as APIKey. At it's conclusion it reports all files modified.
    Start-ReplaceNameAndContent -rootPath "C:\tempRepo" -removalStringValue "asldf23lkrewrlzx34530ae3" -replacementStringValue '$apiKey' -valueType 'APIKey'

    #The Following Example uses a JSON File to remove all values listed with their assigned replacements, and index them by assigned valueType
    Start-ReplaceNameAndContent -rootPath "D:\Scripts" -json -jsonFilePath "D:\scriptConfigs\ReplacementValues.JSON"
    
    .NOTES
    You must exercise extreme caution that you do not rename your userDrive. A Future Version will remove that as a possibility.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, HelpMessage = "Enter the root path.`nExample: C:\tempRepo")]
        [string]$rootPath = $pwd,
        [Parameter(Position = 1,HelpMessage = "Enter the value to replace.`nExample:\'asldf23lkrewrlzx34530ae3\'",ParameterSetName = "Ad-Hoc",Mandatory = $true)]
        [string]$removalStringValue,
        [Parameter(Position = 2,HelpMessage = "Enter the value to replace the previous value WITH`nExample:\'`$apiKey\'",ParameterSetName = "Ad-Hoc",Mandatory = $true)]
        [string]$replacementStringValue,
        [Parameter(Position = 3, HelpMessage = "Enter the valueType that you are replacing.`nExample: \'API Keys\'",ParameterSetName = "Ad-Hoc", Mandatory = $true)]
        [string]$valueType,
        [Parameter(Position = 4, HelpMessage = "Use this switch to use a JSON file",ParameterSetName = "jsonRaw", Mandatory = $true)]
        [switch]$rawJSON,
        [Parameter(position = 5, HelpMessage = "Enter the Path to the JSON File",ParameterSetName = "JSONFile",Mandatory = $true)]
        [string]$jsonFilePath
    )
    Write-Output "Starting Replacement of Names and Content in $rootPath"
   if ($PSCmdlet.ParameterSetName -eq "Ad-Hoc") {
        # Create a replacement object
        $replacements = @(
            [PSCustomObject]@{
                Pattern           = $removalStringValue
                ReplacementValue = $replacementStringValue
                ValueType        = $valueType
            }
        )
    }
    if ($PSCmdlet.ParameterSetName -eq "JSONFile") {
        # Read the JSON file
        if (-not (Test-Path -Path $jsonFilePath)) {
            Write-Error "The specified JSON file does not exist: $jsonFilePath"
            return
        }
        try {
            $replacements = Get-Content -Path $jsonFilePath | ConvertFrom-Json
        } catch {
            Write-Error "Failed to read or parse the JSON file: $_"
            return
        }
    }
    if ($PSCmdlet.ParameterSetName -eq "jsonRaw") {
        # Read the JSON from the pipeline
        try {
            $replacements = $rawJSON | ConvertFrom-Json
        } catch {
            Write-Error "Failed to parse the JSON input: $_"
            return
        }
    }

    $filesModified = @()

    # --- PASS 1: Content Replacement ---
    Write-Verbose "Starting Pass 1: Content Replacement"
    $filesForContent = Get-ChildItem -Path $rootPath -Recurse -File

    foreach ($file in $filesForContent) {
        try {
            $originalContent = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
            $currentContent = $originalContent
            $contentChanged = $false

            foreach ($replacement in $replacements) {
                if ($replacement.ReplacementValue -eq 'SignatureBlock'){
                    $pattern = $replacement.Pattern
                    $currentContent = $currentContent -replace $pattern , $replacement.ReplacementValue
                }
                
                else{
                    if($currentContent -match [regex]::Escape($replacement.Pattern)) {
                    $currentContent = $currentContent -replace [regex]::Escape($replacement.Pattern), $replacement.ReplacementValue
                    }
                }
                    if ($currentContent -ne $originalContent) {
                        $contentChanged = $true
                        $filesModified += [PSCustomObject]@{
                            File        = $file.FullName
                            FileNewName = "N/A"
                            operation   = "File Content Replacement"
                            valueType   = $replacement.ValueType
                        }
                    }
            }
            if ($contentChanged) {
                Set-Content -Path $file.FullName -Value $currentContent -Force -ErrorAction Stop
            }
        }
        catch {
            Write-Warning "An error occurred during content replacement for $($file.FullName): $_"
        }
    }

    # --- PASS 2: Name Replacement ---
    Write-Verbose "Starting Pass 2: Name Replacement"
    $itemsForRenaming = Get-ChildItem -Path $rootPath -Recurse | Sort-Object { $_.FullName.Length } -Descending

    foreach ($item in $itemsForRenaming) {
        $originalPath = $item.FullName
        $currentName = $item.Name
        $newName = $currentName

        # Determine the final name by applying all replacement patterns sequentially
        foreach ($replacement in $replacements) {
            if ($newName -match [regex]::Escape($replacement.Pattern)) {
                $newName = $newName -replace [regex]::Escape($replacement.Pattern), $replacement.ReplacementValue
            }
        }

        # If the calculated new name is different, perform a single rename operation.
        if ($newName -ne $currentName) {
            try {
                Rename-Item -LiteralPath $originalPath -NewName $newName -ErrorAction Stop
                $filesModified += [PSCustomObject]@{
                    File        = $originalPath
                    FileNewName = $newName
                    operation   = if ($item.PSIsContainer) { "Folder Name Replacement" } else { "File Name Replacement" }
                    valueType   = "N/A" # ValueType is ambiguous when multiple patterns could apply.
                }
            }
            catch {
                Write-Warning "Failed to rename '$originalPath' to '$newName'. Error: $_"
            }
        }
    }


    if ($filesModified.count -le 0) {
        Write-Host "No files were modified."
        return
    }
    return $filesModified
}
SignatureBlock


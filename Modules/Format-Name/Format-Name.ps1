function Format-Name {
    <#
    .SYNOPSIS
        Formats a given name to have the first letter capitalized and the rest in lowercase.

    .COMPONENT
        Formatting Functions
    .DESCRIPTION
        This function takes a string input representing a name and formats it such that the first letter of
        each part of the name is capitalized, and the remaining letters are in lowercase. It handles names with spaces,
        hyphenated names, and single-part names.
    .PARAMETER inputName
    The name to be formatted.

    .EXAMPLE
        Format-Name -inputName "john doe"
        Output: "John Doe"
    .NOTES 
        This function is useful for standardizing name formats in user data.
    .OUTPUTS
        A formatted string with proper capitalization.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, HelpMessage = "Enter the Input Name to Format", Mandatory = $true)]
        [string]$inputName
    )
    # Trim leading and trailing spaces
    $inputName = $inputName.Trim()
    $inputNameFormatted = $null

    # Handle names with spaces
    if ($inputName -match " ") {
        $splitInputName = $inputName.Split(" ") | Where-Object { $_ -ne "" } # Remove empty strings caused by extra spaces
        $runningStringPre = $null
        foreach ($splitName in $splitInputName) {
            # Format each part of the name
            if ($splitName.Length -gt 1) {
                $formattedString = $splitName.Substring(0, 1).ToUpper() + $splitName.Substring(1).ToLower()
            } else {
                $formattedString = $splitName.ToUpper() # Handle single-character cases
            }

            # Combine formatted strings
            if ($null -ne $runningStringPre) {
                $runningStringPre = $runningStringPre + " " + $formattedString
            } else {
                $runningStringPre = $formattedString
            }
        }
        $runningStringPost = $runningStringPre
        return $runningStringPost
    }
    # Handle hyphenated names
    if ($inputName -match "-") {
        $splitInputName = $inputName.Split("-")
        if ($splitInputName.Count -eq 2) {
            $formattedString = $splitInputName[0].Substring(0, 1).ToUpper() + $splitInputName[0].Substring(1).ToLower() + "-" +
                               $splitInputName[1].Substring(0, 1).ToUpper() + $splitInputName[1].Substring(1).ToLower()
            return $formattedString
        } else {
            Write-Error "Hyphenated name format is invalid."
        }
    }
    # Handle single-part names
    if ($inputName.Length -gt 1) {
        $inputNameFormatted = $inputName.Substring(0, 1).ToUpper() + $inputName.Substring(1).ToLower()
    } else {
        $inputNameFormatted = $inputName.ToUpper() # Handle single-character names
    }
    return $inputNameFormatted
}
SignatureBlock


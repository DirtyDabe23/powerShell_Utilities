function Export-PublicFolder{
    #Requires -Version 7.0
    #Requires -Module Microsoft.PowerShell.Utility
    #Requires -Module Microsoft.PowerShell.Management
    #Requires -RunAsAdministrator
    #Requires -PSEdition Desktop
    <#
    .SYNOPSIS
    Export a public folder to a PST file using Outlook COM object.
    
    .DESCRIPTION
    This function exports a specified public folder to a PST file using the Outlook COM object
    in PowerShell. It requires the Outlook application to be installed and configured on the machine where the script is run.
    The function takes two parameters: the path of the public folder to export and the path of the PST file to create.
    
    .PARAMETER PublicFolderPath
    Specify the public folder path to export, e.g. 'Public Folders - MyAccount\All Public Folders\$publicFolderPath'.
    
    .PARAMETER PstFilePath
    Specify the full path to the PST file to export to, e.g. 'C:\ExportedPublicFolder.pst'.
    
    .EXAMPLE
    Export-PublicFolder -PublicFolderPath 'MyPublicFolder' -PstFilePath 'C:\Exports\MyPublicFolder.pst'
    This command exports the public folder 'MyPublicFolder' to the specified PST file path.

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
    [Parameter(Mandatory,Position=0,HelpMessage="Specify the public folder path to export, e.g. 'Public Folders - MyAccount\All Public Folders\`$publicFolderPath'.")]
    [string]
    $PublicFolderPath,
    [Parameter(Mandatory,Position=1,HelpMessage="Specify the full path to the PST file to export to, e.g. 'C:\ExportedPublicFolder.pst'.")]
    [string]
    $PstFilePath
    )
    ## Initialize the Outlook COM Object
    $Outlook = New-Object -ComObject Outlook.Application
    ## Compose the top public folder path <Public Folders - ACCOUNT_NAME\All Public Folders>
    $outlookSessionFolders = $Outlook.Session.Folders | Where-Object { $_.Name -like "Public Folders -*" }
    ## Append the specified $PublicFolderPath
    $PublicFolderPath = (($outlookSessionFolders.Name) + '\All Public Folders\' + $PublicFolderPath)
    Write-Verbose "Public Folder Parent = $PublicFolderPath"
    ## Split the folder path into levels
    $pfPath = $PublicFolderPath.Split('\')
    ## Initialize the public folder object to export.
    $PublicFolderToExport = $Outlook.Session.Folders.Item($pfPath[0]).Folders.Item($pfPath[1])
    ## Append each public folder level
    for ($i = 2; $i -lt ($pfPath.count); $i++) {
        try {
        $PublicFolderToExport = $PublicFolderToExport.Folders.Item($pfPath[$i])
        }
        catch {
            ## If the folder name does not exist, terminate the script.
            "The public folder path [$($PublicFolderPath)] does not exist." | Out-Default
            return $null
        }
    }
    Write-Verbose $($PublicFolderToExport.FullFolderPath)
    ## Create the PST export folder if it doesn't exist.
    $pstFolder = Split-Path $PstFilePath -Parent
    if (!(Test-Path $pstFolder)) {
        try {
            $null = New-Item -Type Directory -Path $pstFolder -ErrorAction Stop
            Write-Verbose "Output folder [$pstFolder] created."
        }
        catch {
            Write-Error "Failed to create the folder [$pstFolder]."
            Write-Error $_.Exception.Message
            return $null
        }
    }
    ## Initialize the PST store
    $namespace = $Outlook.GetNameSpace("MAPI")
    ## Attach the PST to the Outlook session
    $namespace.AddStore($PstFilePath)
    $pstOutlookStore = $namespace.Session.Folders.GetLast()
    Write-Verbose "PST [$PstFilePath] attached as [$($pstOutlookStore.Name)]."
    ## Start export.
    Write-Verbose "Start public folder export to [$PstFilePath]."
    [void]$PublicFolderToExport.To($pstOutlookStore)
    Write-Verbose "Start public folder export is finished."
    ## Detach PST from Outlook
    $namespace.RemoveStore($pstOutlookStore)
    Write-Verbose "PST [$PstFilePath] detached."
    $outlook.Application.quit()
    return $pstOutlookStore
}
SignatureBlock


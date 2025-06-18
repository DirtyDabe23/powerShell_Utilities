#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
 
Function Copy-ListItems()
{
    param
    (
        [Parameter(Mandatory=$true)] [string] $SiteURL,
        [Parameter(Mandatory=$true)] [string] $SourceListName,
        [Parameter(Mandatory=$true)] [string] $TargetListName
    )   
    Try {
        #Setup Credentials to connect
        $Cred = Get-Credential
        $Cred = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.UserName,$Cred.Password)
     
        #Setup the context
        $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
        $Ctx.Credentials = $Cred
 
        #Get the Source List and Target Lists
        $SourceList = $Ctx.Web.Lists.GetByTitle($SourceListName)
        $TargetList = $Ctx.Web.Lists.GetByTitle($TargetListName)
     
        #Get All Items from Source List
        $SourceListItems = $SourceList.GetItems([Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery())
        $Ctx.Load($SourceListItems)
        $Ctx.ExecuteQuery()
     
        #Get All fields from Source List & Target List
        $SourceListFields = $SourceList.Fields
        $Ctx.Load($SourceListFields)
        $TargetListFields = $TargetList.Fields
        $Ctx.Load($TargetListFields)       
        $Ctx.ExecuteQuery()
 
        #Get each column value from source list and add them to target
        ForEach($SourceItem in $SourceListItems)
        {
            $NewItem =New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
            $ListItem = $TargetList.AddItem($NewItem)       
  
            #Map each field from source list to target list
            Foreach($SourceField in $SourceListFields)
            { 
                #Skip Read only, hidden fields, content type and attachments
                If((-Not ($SourceField.ReadOnlyField)) -and (-Not ($SourceField.Hidden)) -and ($SourceField.InternalName -ne  "ContentType") -and ($SourceField.InternalName -ne  "Attachments") ) 
                {
                    $TargetField = $TargetListFields | where { $_.Internalname -eq $SourceField.Internalname}
                    if($TargetField -ne $null)
                    {
                        #Copy column value from source to target
                        $ListItem[$TargetField.InternalName] = $SourceItem[$SourceField.InternalName] 
                    }
                }
            }
            $ListItem.update()
            $Ctx.ExecuteQuery()
        }
 
        write-host  -f Green "Total List Items Copied from '$SourceListName' to '$TargetListName' : $($SourceListItems.count)"
    }
    Catch {
        write-host -f Red "Error Copying List Items!" $_.Exception.Message
    }
}
 
#Set Parameters
$SiteURL= "https://uniqueParentCompanyinc.sharepoint.com/materials/intercompanytransfers/sourceLocation3/"
$SourceListName="Transfer Requests"
$TargetListName="2019-2020"
 
#Call the function to copy list items
Copy-ListItems -siteURL $SiteURL -SourceListName $SourceListName -TargetListName $TargetListName


#Read more: https://www.sharepointdiary.com/2017/01/sharepoint-online-copy-list-items-to-another-list-using-powershell.html#ixzz7uvcqUxgT
# SIG # Begin signature block#Script Signature# SIG # End signature block






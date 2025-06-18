Connect-AzureAD

# Edit this variable with the desired OU
$searchOU = "OU=anonSubsidiary-1 Users,OU=AAD Connect Sync OU,DC=TOWERCOMPONENTS,DC=local"
# Edit the DNS Domain Name for this location
$dnsDomainName = "towercomponents.local"


Class Attributes {
    $AAD = $string
    $AD = $string
}

$attributeMap = @(
    [Attributes]@{AAD = "PhysicalDeliveryOfficeName"; AD = "Office"},
    [Attributes]@{AAD = "JobTitle"; AD = "Title"},
    [Attributes]@{AAD = "Department"; AD = "Department"},
    [Attributes]@{AAD = "CompanyName"; AD = "Company"},
    [Attributes]@{AAD = "TelephoneNumber"; AD = "OfficePhone"},
    [Attributes]@{AAD = "DisplayName"; AD = "DisplayName"},
    [Attributes]@{AAD = "GivenName"; AD = "GivenName"},
    [Attributes]@{AAD = "Surname"; AD = "Surname"}
)

$locADUsers = Get-ADUser -Server $dnsDomainName -filter * -SearchBase $searchOU -Properties * | Sort-Object -Property UserPrincipalName

foreach ($locADUser in $locADUsers) {
    Write-Host "`nNow serving:"$locADUser.UserPrincipalName"`n"

    try {
        $AADUser = Get-AzureADUser -objectID $locADUser.UserPrincipalName
    }
    catch {
        $AADUser = $null
    }
    
    if($AADUser) {
        $params = @{
            Identity = $locADUser
            Country = "US"
        }
        # try {
        #     $currentManager = (Get-aduser -Server $dnsDomainName $locADUser.manager).UserPrincipalName
        # }
        # catch {
        #     $currentManager = $null
        # }
        # try {
        #     $AADManager = (Get-AzureADUserManager -ObjectId $AADUser.UserPrincipalName).UserPrincipalName
        #     $manager = $AADManager.split("@")
        # }
        # catch {
        #     $AADManager = $null
        #     $manager = $null
        # }
        # if ($AADManager -ne $currentManager) {
        #     $params += @{Manager = $manager[0]}
        #     write-host "USER: "$locADUser.UserPrincipalName"ATTRIBUTE: Manager updating to"$manager[0]
        # }
        
        foreach ($line in $attributeMap) {
            $ladAtrName = $line.AD
            $aadAtrName = $line.AAD
            if(($locADUser.$ladAtrName -ne $AADUser.$aadAtrName) -and ($null -ne $AADUser.$aadAtrName)) {
                write-host "USER:"$locADUser.UserPrincipalName "ATTRIBUTE: $ladAtrName updating from " $locADUser.$ladAtrName "to" $AADUser.$aadAtrName
                $AADval = $AADUser.$aadAtrName.trim()
                $params += @{$ladAtrName = $AADVal}
            }
        }

        Set-ADUser @params -Server $dnsDomainName -add @{ProxyAddresses = $AADUser.proxyaddresses -split ","}

    } else {
        Write-Host -BackgroundColor Red -ForegroundColor Cyan "USER:" $locADUser.UserPrincipalName "does not exist in AzureAD"
    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block






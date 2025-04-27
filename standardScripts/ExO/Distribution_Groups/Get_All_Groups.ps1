#connect to Exchange Online
$exoCertThumb = "f5fae1b6ead4efdf33c5a79175561763cac5fb16"
$exoAppID = "1f97c81e-f222-4046-967a-5051db6f1ec1"
$exoORG = "uniqueParentCompanyinc.onmicrosoft.com"
		
Connect-ExchangeOnline -CertificateThumbPrint $exoCertThumb -AppID $exoAppID -Organization $exoORG

#This stores all distribution Groups into a variable
$DistroGroups = Get-DistributionGroup -resultsize unlimited
#Get the date for File Naming Items
$Date = Get-Date -Format yyyy.MM.dd
#The path all files will be stored at 
$rootPath = "C:\Users\$userName\uniqueParentCompany, Inc\GIT IT Support - General\Projects\Distrolist Renovation\"

#This loop goes through each distribution group, and based on the name of the distribution group, creates a unique file name for it. The display name and email address are stored for later use.
ForEach ($DistroGroup in $DistroGroups)
{ 
    #Unique Filename Generated here
    $fileName = $Date+ "."+$DistroGroup.Name+".csv"
    #Full Path for the file export is generated from the root path and the file name.
    $realPath = $rootpath + $filename
    #Stores the DisplayName and Email Address of the Distribution Group here, makes it easier to pass with add-member
    $dispName = $DistroGroup.DisplayName
    $addr =  $DistroGroup.PrimarySMTPAddress
    Try
    {
    #This command gets all Distribution Group Members, and selects only the properties that we care about
    $data = Get-DistributionGroupMember -Identity $DistroGroup.Id -ResultSize Unlimited | Select-Object -Property "DisplayName","FirstName","LastName","Title","PrimarySMTPAddress","Manager","RecipientType","RecipientTypeDetails"
    #This adds new properties, which translate over to columns for the CSV. It adds in the group's email address, as well as the group's display name.
    $data | Add-Member -MemberType NoteProperty -Name "Group Email" -Value $addr
    $data | Add-Member -MemberType NoteProperty -Name "Group Display Name" -Value $dispName
    #This exports the item as a CSV 
    $data | Export-Csv -Path $realPath -NoTypeInformation
     
    }
    Catch
    {
    $ErrorGroup = $DistroGroup.Name
    $ErrorLog +=  $ErrorGroup
    }
}
#The same as the above, but for Dynamic Distribution Groups 
$DistroGroups = Get-DynamicDistributionGroup -resultsize unlimited
ForEach ($DistroGroup in $DistroGroups)
{ 
    $fileName = $Date+ "."+"DD"+"."+$DistroGroup.Name+".csv"
    $realPath = $rootpath + $filename
    $dispName = $DistroGroup.DisplayName
    $addr =  $DistroGroup.PrimarySMTPAddress
    Try
    {
    $data = Get-DynamicDistributionGroupMember -Identity $DistroGroup.Id -ResultSize Unlimited | Select-Object -Property "DisplayName","FirstName","LastName","Title","PrimarySMTPAddress","Manager","RecipientType","RecipientTypeDetails"
    $data | Add-Member -MemberType NoteProperty -Name "Group Email" -Value $addr
    $data | Add-Member -MemberType NoteProperty -Name "Group Display Name" -Value $dispName
    $data | Export-Csv -Path $realPath -NoTypeInformation
    }
    Catch
    {
    $ErrorGroup = $DistroGroup.Name 
    $ErrorLog +=  $ErrorGroup
    }
}
# SIG # Begin signature block#Script Signature# SIG # End signature block






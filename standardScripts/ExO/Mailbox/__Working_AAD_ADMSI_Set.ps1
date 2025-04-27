# Set the credentials to connect to Azure AD
$credential = Get-Credential
Connect-AzureAD -Credential $credential

# Import the CSV file
$csvPath = "C:\Temp\Contacts2.csv"
$users = Import-Csv $csvPath

# Iterate through the users in the CSV file and set their Azure AD properties
foreach ($user in $users) {
    # Get the user's object ID
    $objID = (Get-AzureADUser -SearchString $users.DisplayName).objectID

    # Set the Azure AD properties for the user based on the CSV entry
    Set-AzureADUser -ObjectId $objID `
                    -Mobile $user.MobilePhone `
                    -TelephoneNumber $user.TelephoneNumber `
                    -JobTitle $user.JobTitle `
                    -ShowInAddressList $true

                  
}
# SIG # Begin signature block#Script Signature# SIG # End signature block




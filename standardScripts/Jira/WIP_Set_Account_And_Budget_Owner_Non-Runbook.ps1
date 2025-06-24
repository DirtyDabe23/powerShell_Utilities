param(
    [string] $reporter,
    [string] $accountNumber,
    [string] $ghdKey,
    [string] $procKey   
)

#Items that are pushed into the Procurement Ticket from the Automation on Creation
$reporter = "Automation For Jira"
$procKey = "PROC-695"
$ghdKey = "GHD-29752"
$accountNumber = $null


#Values that will need to be determined by the parent ticket.
$officeLocation = $null 
$department = $null 

#GHD Ticket for Data Retrieval
$Issue = Invoke-RestMethod -Method get -uri "https://parentCompany.atlassian.net/rest/api/2/issue/$ghdKey" -Headers $headers

$officeLocation = $issue.fields.customfield_10787.value
$officeLocationID =  [int]$issue.fields.customfield_10787.id 
$department = $issue.fields.customfield_10787.child.value
$departmentID = [int]$issue.fields.customfield_10787.child.id 


$ttProduction = "Assembly" `
, "Cage/Inventory" `
, "Coil - Non-Welder" `
, "Coil - Welder" `
, "Control Panel" `
, "Electrical" `
, "Evaporator" `
, "Evaporator Coil" `
, "Evaporator Support" `
, "High Side Custom Engineering" `
, "Low Side Assembly" `
, "Low Side Custom Engineering" `
, "Maintenance, Machinery, & Equipment" `
, "Manufacturing Engineering" `
, "Materials" `
, "Operator Associate" `
, "Parts" `
, "Plant Management" `
, "Production" `
, "Production Control" `
, "Quality - Office" `
, "Quality - Shop" `
, "Research & Development" `
, "Safety - Office" `
, "Safety - Shop" `
, "Sheet Metal" `
, "Shop Office" `
, "Stockroom, Warehouse, Part Order, Shipping" `
,"Sub-Assembly & Support","Traffic","Welding"

$validAccountNumber = "6680-01-01" `
, "6680-01-02"`
, "6680-01-03"`
, "6680-01-04"`
, "6680-01-05"`
, "6680-01-06"`
, "6680-01-07"`
, "6680-01-09"`
, "6680-01-12"`
, "6680-01-13"`
, "6680-01-14"`
, "6680-01-16"`
, "6680-02-00"`
, "6680-02-20"`
, "6680-03-00"`
, "6680-06-00"`
, "1310-01-00"`
, "1345-01-00"`
, "1346-01-00"`
, "1355-01-00"`
, "1380-01-00"`
, "1398-01-00"`
, "1554-01-00"`
, "1557-01-00"`
, "6850-01-00"`
, "1335-01-00"`
, "2600-03-00"`
, "1325-01-00"`
, "1318-01-00"







If ($null -eq $accountNumber)
{
    If ($officeLocation -eq 'parentCompany East')
    {
        if ($department -eq 'Marketing Refrigeration')
        {
            $accountNumber = "6680-01-01"
            $budgetOwner = "Joe Sunnarborg"
        }
        if ($department -eq 'Marketing HVAC')
        {
            $accountNumber = "6680-01-02"
            $budgetOwner = "Chad Nagle"
        }
        if ($department -eq 'Product Development - HVAC')
        {
            $accountNumber = "6680-01-03"
            $budgetOwner = "Jennifer Hamilton"
        }
        if ($department -in $ttProduction)
        {
            $accountNumber = "6680-01-04"
            $budgetOwner = "William Jones"
        }
        if ($department -eq 'Finance')
        {
            $accountNumber = "6680-01-05"
            $budgetOwner = "Jeff Finch"
        }
        if ($department -eq 'Executive')
        {
            $accountNumber = "6680-01-06"
            $budgetOwner = "Mike Hilker"
        }
        if ($department -eq 'Product Development')
        {
            $accountNumber = "6680-01-07"
            $budgetOwner = "Mark Huber"
        }
        if ($department -eq 'Product Development')
        {
            $accountNumber = "6680-01-07"
            $budgetOwner = "Mark Huber"
        }
        if ($department -eq 'Product Development - Refrigeration')
        {
            $accountNumber = "6680-01-09"
            $budgetOwner = "Trevor Hegg"
        }
        if ($department -eq 'parentCompanyld')
        {
            $accountNumber = "6680-01-12"
            $budgetOwner = "Kurt Leibendorfer"
        }
        if ($department -eq 'Water Systems')
        {
            $accountNumber = "6680-01-13"
            $budgetOwner = "Chris Nagle"
        }
        if ($department -eq 'People Operations')
        {
            $accountNumber = "6680-01-14"
            $budgetOwner = "Jeff Poczekaj"
        }
        if ($department -eq 'Global Information Technology')
        {
            $accountNumber = "6680-01-16"
            $budgetOwner = "Mike Hilker"
        }
        if ($department -eq 'Customer Solutions')
        {
            $accountNumber = "Unknown"
            $budgetOwner = "Unknown"
        }
    }
    If ($officeLocation -eq 'parentCompany Alcoil, Inc.')
    {
        $accountNumber = "1398-01-00"
        $budgetOwner = "John Kollasch"
    }
    If ($officeLocation -eq 'parentCompany Australia (Pty.) Ltd.')
    {
        $accountNumber = "1335-01-00"
        $budgetOwner = "Alex Eisold"
    }
    If ($officeLocation -eq 'parentCompany Dry Cooling, Inc.')
    {
        $accountNumber = "1346-01-00"
        $budgetOwner = "Toby Athron"
    }
    If ($officeLocation -eq 'parentCompany Europe BVBA')
    {
        $accountNumber = "1310-01-00"
        $budgetOwner = "Ivan Jorissen"
    }
    If ($officeLocation -eq 'parentCompany Iowa')
    {
        $accountNumber = "6680-06-00"
        $budgetOwner = "Brett Meyer"
    }
    If ($officeLocation -eq 'parentCompany LMP')
    {
        $accountNumber = "1554-01-00"
        $budgetOwner = "Jeffrey Gingras"
    }
    If ($officeLocation -eq 'parentCompany Midwest')
    {
        $accountNumber = "6680-02-00"
        $budgetOwner = "Michael Giannavola"
    }
    If ($officeLocation -eq 'parentCompany Iowa')
    {
        $accountNumber = "6680-06-00"
        $budgetOwner = "Brett Meyer"
    }
    If ($officeLocation -eq 'parentCompany Newton')
    {
        $accountNumber = "6680-02-20"
        $budgetOwner = "Michael Giannavola"
    }
    If ($officeLocation -eq 'parentCompany Select Tech')
    {
        $accountNumber = "1557-01-00"
        $budgetOwner = "Eric Staley"
    }
    If ($officeLocation -eq 'Location2')
    {
        $accountNumber = "6680-03-00"
        $budgetOwner = "Doug Bradley"
    }
    If ($officeLocation -eq 'subsidiaryCompany2, Inc.')
    {
        $accountNumber = "1345-01-00"
        $budgetOwner = "Don Dobney"
    }
    If ($officeLocation -eq 'subsidiaryCompany1')
    {
        $accountNumber = "1380-01-00"
        $budgetOwner = "Alex Eisold"
    }
    If ($officeLocation -eq 'subsidiaryCompany4')
    {
        $accountNumber = "1355-01-00"
        $budgetOwner = "Brian Walker"
    }
}

Else
{
   If ($accountNumber -notin $validAccountNumber)
    {
        Write-Output "Account Number is Invalid. Reverting to Office Location and Department."
        If ($officeLocation -eq 'parentCompany East')
        {
            if ($department -eq 'Marketing Refrigeration')
            {
                $accountNumber = "6680-01-01"
                $budgetOwner = "Joe Sunnarborg"
            }
            if ($department -eq 'Marketing HVAC')
            {
                $accountNumber = "6680-01-02"
                $budgetOwner = "Chad Nagle"
            }
            if ($department -eq 'Product Development - HVAC')
            {
                $accountNumber = "6680-01-03"
                $budgetOwner = "Jennifer Hamilton"
            }
            if ($department -in $ttProduction)
            {
                $accountNumber = "6680-01-04"
                $budgetOwner = "William Jones"
            }
            if ($department -eq 'Finance')
            {
                $accountNumber = "6680-01-05"
                $budgetOwner = "Jeff Finch"
            }
            if ($department -eq 'Executive')
            {
                $accountNumber = "6680-01-06"
                $budgetOwner = "Mike Hilker"
            }
            if ($department -eq 'Product Development')
            {
                $accountNumber = "6680-01-07"
                $budgetOwner = "Mark Huber"
            }
            if ($department -eq 'Product Development')
            {
                $accountNumber = "6680-01-07"
                $budgetOwner = "Mark Huber"
            }
            if ($department -eq 'Product Development - Refrigeration')
            {
                $accountNumber = "6680-01-09"
                $budgetOwner = "Trevor Hegg"
            }
            if ($department -eq 'parentCompanyld')
            {
                $accountNumber = "6680-01-12"
                $budgetOwner = "Kurt Leibendorfer"
            }
            if ($department -eq 'Water Systems')
            {
                $accountNumber = "6680-01-13"
                $budgetOwner = "Chris Nagle"
            }
            if ($department -eq 'People Operations')
            {
                $accountNumber = "6680-01-14"
                $budgetOwner = "Jeff Poczekaj"
            }
            if ($department -eq 'Global Information Technology')
            {
                $accountNumber = "6680-01-16"
                $budgetOwner = "Mike Hilker"
            }
            if ($department -eq 'Customer Solutions')
            {
                $accountNumber = "Unknown"
                $budgetOwner = "Unknown"
            }
        }
        If ($officeLocation -eq 'parentCompany Alcoil, Inc.')
        {
            $accountNumber = "1398-01-00"
            $budgetOwner = "John Kollasch"
        }
        If ($officeLocation -eq 'parentCompany Australia (Pty.) Ltd.')
        {
            $accountNumber = "1335-01-00"
            $budgetOwner = "Alex Eisold"
        }
        If ($officeLocation -eq 'parentCompany Dry Cooling, Inc.')
        {
            $accountNumber = "1346-01-00"
            $budgetOwner = "Toby Athron"
        }
        If ($officeLocation -eq 'parentCompany Europe BVBA')
        {
            $accountNumber = "1310-01-00"
            $budgetOwner = "Ivan Jorissen"
        }
        If ($officeLocation -eq 'parentCompany Iowa')
        {
            $accountNumber = "6680-06-00"
            $budgetOwner = "Brett Meyer"
        }
        If ($officeLocation -eq 'parentCompany LMP')
        {
            $accountNumber = "1554-01-00"
            $budgetOwner = "Jeffrey Gingras"
        }
        If ($officeLocation -eq 'parentCompany Midwest')
        {
            $accountNumber = "6680-02-00"
            $budgetOwner = "Michael Giannavola"
        }
        If ($officeLocation -eq 'parentCompany Iowa')
        {
            $accountNumber = "6680-06-00"
            $budgetOwner = "Brett Meyer"
        }
        If ($officeLocation -eq 'parentCompany Newton')
        {
            $accountNumber = "6680-02-20"
            $budgetOwner = "Michael Giannavola"
        }
        If ($officeLocation -eq 'parentCompany Select Tech')
        {
            $accountNumber = "1557-01-00"
            $budgetOwner = "Eric Staley"
        }
        If ($officeLocation -eq 'Location2')
        {
            $accountNumber = "6680-03-00"
            $budgetOwner = "Doug Bradley"
        }
        If ($officeLocation -eq 'subsidiaryCompany2, Inc.')
        {
            $accountNumber = "1345-01-00"
            $budgetOwner = "Don Dobney"
        }
        If ($officeLocation -eq 'subsidiaryCompany1')
        {
            $accountNumber = "1380-01-00"
            $budgetOwner = "Alex Eisold"
        }
        If ($officeLocation -eq 'subsidiaryCompany4')
        {
            $accountNumber = "1355-01-00"
            $budgetOwner = "Brian Walker"
        }
    }
   else 
   {
        switch ($accountNumber) {
            "6680-01-01"{$BudgetOwner = "Joe Sunnarborg"}
            "6680-01-02"{$BudgetOwner = "Chad Nagle"}
            "6680-01-03"{$BudgetOwner = "Jennifer Hamilton"}
            "6680-01-04"{$BudgetOwner = "William Jones"}
            "6680-01-05"{$BudgetOwner = "Jeff Finch"}
            "6680-01-06"{$BudgetOwner = "Mike Hilker"}
            "6680-01-07"{$BudgetOwner = "Mark Huber"}
            "6680-01-09"{$BudgetOwner = "Trevor Hegg"}
            "6680-01-12"{$BudgetOwner = "Kurt Leibendorfer"}
            "6680-01-13"{$BudgetOwner = "Chris Nagle"}
            "6680-01-14"{$BudgetOwner = "Jeff Poczekaj"}
            "6680-01-16"{$BudgetOwner = "Mike Hilker"}
            "6680-02-00"{$BudgetOwner = "Michael Giannavola"}
            "6680-02-20"{$BudgetOwner = "Michael Giannavola"}
            "6680-03-00"{$BudgetOwner = "Doug Bradley"}
            "6680-06-00"{$BudgetOwner = "Brett Meyer"}
            "1310-01-00"{$BudgetOwner = "Ivan Jorissen"}
            "1345-01-00"{$BudgetOwner = "Don Dobney"}
            "1346-01-00"{$BudgetOwner = "Toby Athron"}
            "1355-01-00"{$BudgetOwner = "Brian Walker"}
            "1380-01-00"{$BudgetOwner = "Alex Eisold"}
            "1398-01-00"{$BudgetOwner = "John Kollasch"}
            "1554-01-00"{$BudgetOwner = "Jeffrey Gingras"}
            "1557-01-00"{$BudgetOwner = "Eric Staley"}
            "6850-01-00"{$BudgetOwner = "Comcast"}
            " 1335-01-00"{$BudgetOwner = "Alex Eisold"}
            "2600-03-00"{$BudgetOwner = "Doug Bradley"}
            "1325-01-00"{$BudgetOwner = "Cristina Garavaglia"}
            "1318-01-00"{$BudgetOwner = "Tina Lindkvist"}
        }
   } 

}


If (($null -eq $accountNumber) -and ($null -eq $budgetOwner))
{
    Write-Output "Not valid. Please contact GIT for Assistance"
    Exit 1 
}
else {
    $payload = @{
        "update" = @{
            "customfield_10721" = @(
                @{
                    "set" = "$accountNumber"
                }
            )
            "customfield_10787" = @(
                @{
                    "set" = $officeLocationID
                    "child" = @{
                        "set" = $departmentID
                    }
                }
            )
            "customfield_10872" = @(
                @{
                    "set" = "$BudgetOwner"
                }
            )
        }
    }
    
    # Convert the payload to JSON
    $jsonPayload = $payload | ConvertTo-Json -Depth 10
    
Invoke-RestMethod -Uri "https://parentCompany.atlassian.net/rest/api/2/issue/$($procKey)" -Method Put -Body $jsonPayload -Headers $headers

}

SignatureBlock


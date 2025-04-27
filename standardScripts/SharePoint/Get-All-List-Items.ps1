  # Fetch Subsites
    $listData = @()
    $uri = '/v1.0/sites/',$taneytownRoster.ID, '/lists/', $list.ID ,'/items?expand=fields' -join ""
    $response = invoke-graphrequest -Uri $uri -Method Get -ErrorAction Stop
    $listData += $response.value

    # Pagination Handling
    while ($response.'@odata.nextLink') {
        $response = invoke-graphrequest -Uri $response.'@odata.nextLink' -Method Get
        $listData += $response.value
    }

# SIG # Begin signature block#Script Signature# SIG # End signature block




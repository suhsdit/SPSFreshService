Function Get-FreshServiceAPIResult {
    Param(
        [Parameter()]
            [String]$APIEndpoint,
        [Parameter()]
            [String]$PrimaryObject,
        [Parameter()]
            [Boolean]$Paginate,
        [Parameter()]
            [String]$Method,
        [Parameter()]
            [String]$Body,
        [Parameter()]
            [int32]$Pages = 10000
    )
    try {
        # Check for $body which would indicate a POST or PUT
        if ($Body) {
            Write-Verbose -Message "Final APIEndpoint is: $($APIEndpoint)"
            Invoke-WebRequest -Uri $APIEndpoint -Body $Body -Method $Method -Headers $headers
        }
        # Check for $Paginate which would indicate a GET with pagination
        if ($Paginate) {
            $ResultsPerPage = 100
            $Page = 1
            $Result = $null
            $TotalValues = [double]::PositiveInfinity
            # [double]::PositiveInfinity is used to ensure that the first page of results is always returned
            

            if ($APIEndpoint -like '*`?*') {
                $APIEndpoint = "$($APIEndpoint)&"
            } else {
                $APIEndpoint = "$($APIEndpoint)?"
            }

            while ($TotalValues -ge 100 -and $Page -le $Pages) {
                $APIEndpoint = "$($APIEndpoint)per_page=$($ResultsPerPage)&page=$($Page)"
                Write-Verbose -Message "Final APIEndpoint is: $($APIEndpoint) (with pagination)"
                $Page++
                $WebRequestResult = Invoke-WebRequest -Uri $APIEndpoint -Method $Method -Headers $headers
                $Result += ($WebRequestResult | ConvertFrom-Json).$PrimaryObject
                $TotalValues = ($WebRequestResult | ConvertFrom-Json).$PrimaryObject.count
            }
        }
        # If neither $Paginate or $Body are set, then it's a GET without pagination or
        # it is the last page of a GET with pagination
        if (!$Paginate -and !$Body) {
            $Result = $null
            Write-Verbose -Message "Final APIEndpoint is: $($APIEndpoint) (without pagination)"
            $WebRequestResult = Invoke-WebRequest -Uri $APIEndpoint -Method $Method -Headers $headers
            if ($PrimaryObject){
                $Result = ($WebRequestResult.content | ConvertFrom-Json).$PrimaryObject
            } else {
                $Result = ($WebRequestResult.content | ConvertFrom-Json)
            }
        }
    $Result
    }
    catch {
        Write-Error -Message "$_ went wrong."
    }
}
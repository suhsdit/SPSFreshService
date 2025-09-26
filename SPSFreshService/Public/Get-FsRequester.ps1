Function Get-FsRequester {
<#
.SYNOPSIS
    Gets one or more requesters from FreshService
.DESCRIPTION
    The Get-FsRequester function gets requesters from your FreshService domain
.EXAMPLE
    Get-FsRequester
    Get all requesters 
.PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
    [CmdletBinding()] #Enable all the default paramters, including
    Param(
        [Parameter(Mandatory=$false,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
            [String]$LastName,

        [Parameter(Mandatory=$false,
            Position=1)]
            [String]$Email,

        [Parameter(Mandatory=$false,
            Position=2)]
            [String]$CompanyDomain,

        [Parameter(Mandatory=$false,
            Position=2)]
            [String]$ID
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
        $APIEndpoint = "$($APIURL)/requesters"
    } Process {
        $Company = Get-FsDepartment -Domain $CompanyDomain
        $CompanyID = $Company.id
        
        if ($LastName -or $Email -or $CompanyDomain) {
            $APIEndpoint += "?query=`""
            if ($LastName) {$APIEndpoint += "last_name:$($LastName) AND "}
            if ($Email) {$APIEndpoint += "primary_email:'$([uri]::EscapeDataString($Email))' AND "}
            if ($CompanyDomain) {$APIEndpoint += "department_id:$($CompanyID) AND "}
            $APIEndpoint = $APIEndpoint -replace "\s.{3}\s$","`""
            Write-Verbose "so far after params and regex: $($APIEndpoint)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'requesters' -Paginate $false -Method 'Get'
        } 
        elseif ($ID) {
            $APIEndpoint += "/$($ID)"
            Write-Verbose "so far after params and regex: $($APIEndpoint)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'requester' -Paginate $false -Method 'Get'
        } 
        else {
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'requesters' -Paginate $true -Method 'Get'
        }
    } End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
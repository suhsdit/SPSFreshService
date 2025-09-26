Function Get-FsAgent {
<#
.SYNOPSIS
    Gets one or more Agents from FreshService
.DESCRIPTION
    The Get-FsAgent function gets agents from your FreshService domain
    test
.EXAMPLE
    Get-FsAgent
    Get all agents 
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
            [String]$FirstName,

        [Parameter(Mandatory=$false,
            Position=1)]
            [String]$Email,

        [Parameter(Mandatory=$false,
            Position=2)]
            [String]$ID
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
        $APIEndpoint = "$($APIURL)/agents"
    } Process {
        if ($FirstName -or $Email) {
            $APIEndpoint += "?query=`""
            if ($FirstName) {$APIEndpoint += "first_name:$($FirstName) AND "}
            if ($Email) {$APIEndpoint += "email:'$([uri]::EscapeDataString($Email))' AND "}
            $APIEndpoint = $APIEndpoint -replace "\s.{3}\s$","`""
            Write-Verbose "so far after params and regex: $($APIEndpoint)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'agents' -Paginate $false -Method 'Get'
        }
        elseif ($ID) {
            $APIEndpoint += "/$($ID)"
            Write-Verbose "so far after params and regex: $($APIEndpoint)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'agent' -Paginate $false -Method 'Get'
        }
        else {
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'agents' -Paginate $true -Method 'Get'
        }
    } End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
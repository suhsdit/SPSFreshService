Function Get-FsRequesterGroup {
<#
.SYNOPSIS
    Gets one or more group of requesters from FreshService
.DESCRIPTION
    The Get-FsRequesterGroup function gets requester groups from your FreshService domain
.EXAMPLE
    Get-FsRequesterGroup
    Get all requester groups
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
            [String[]]$ID
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
        $APIEndpoint = "$($APIURL)/requester_groups"
    } Process {
        if ($ID) {
            write-verbose -Message "Using parameter"
            $APIEndpoint = "$($APIEndpoint)/$($ID)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'requester_group' -Paginate $false -Method 'Get'
        } else {
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'requester_groups' -Paginate $true -Method 'Get'
        }
    } End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
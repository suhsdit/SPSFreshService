Function Get-FsAgentGroup {
<#
.SYNOPSIS
    Gets one or more groups of agents from FreshService
.DESCRIPTION
    The Get-FsAgentGroup function gets agent groups from your FreshService domain
.EXAMPLE
    Get-FsAgentGroup
    Get all agent groups
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
        $APIEndpoint = "$($APIURL)/groups"
    } Process {
        if ($ID) {
            write-verbose -Message "Using parameter"
            $APIEndpoint = "$($APIEndpoint)/$($ID)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'group' -Paginate $false -Method 'Get'
        } else {
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'groups' -Paginate $true -Method 'Get'
        }
    } End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
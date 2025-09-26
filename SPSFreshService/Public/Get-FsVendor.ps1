Function Get-FsVendor {
<#
.SYNOPSIS
    Gets one or more vendors from FreshService
.DESCRIPTION
    The Get-FsVendor function gets vendors from your FreshService domain
.EXAMPLE
    Get-FsVendor
    Get all vendors
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
            [String]$ID
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
        $APIEndpoint = "$($APIURL)/vendors"
    } Process {
        if ($ID) {
            write-verbose -Message "Using parameter"
            $APIEndpoint = "$($APIEndpoint)/$($ID)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'vendor' -Paginate $false -Method 'Get'
        } else {
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'vendors' -Paginate $true -Method 'Get'
        }
    } End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
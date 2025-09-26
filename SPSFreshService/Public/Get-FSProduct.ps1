Function Get-FsProduct {
<#
.SYNOPSIS
    Gets one or more Products from FreshService
.DESCRIPTION
    The Get-FsProduct function gets products from your FreshService domain
.EXAMPLE
    Get-FsProduct
    Get all products 
.PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
[CmdletBinding()] #Enable all the default paramters, including
Param(
)
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
        $APIEndpoint = "$($APIURL)/products"
    } Process {
        Write-Verbose "so far after params and regex: $($APIEndpoint)"
        Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'products' -Paginate $true -Method 'Get'
    } End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
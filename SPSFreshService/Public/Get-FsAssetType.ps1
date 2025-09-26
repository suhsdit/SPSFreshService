Function Get-FsAssetType {
<#
.SYNOPSIS
    Gets one or more Assets Types from FreshService
.DESCRIPTION
    The Get-FsAsset function gets asset types from your FreshService domain
.EXAMPLE
    Get-FsAssetType
    Get all asset types
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
        $APIEndpoint = "$($APIURL)/asset_types"
    } Process {
        if ($ID) {
            write-verbose -Message "Using parameter"
            $APIEndpoint = "$($APIEndpoint)/$($ID)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'asset_type' -Paginate $false -Method 'Get'
        } else {
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'asset_types' -Paginate $true -Method 'Get'
        }
    } End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
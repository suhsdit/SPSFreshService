Function Get-FsAsset {
<#
.SYNOPSIS
    Gets one or more Assets from FreshService
.DESCRIPTION
    The Get-FsAsset function gets assets from your FreshService domain
.EXAMPLE
    Get-FsAsset
    Get all assets 
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
            [String]$Name,

        [Parameter(Mandatory=$false,
            Position=1)]
            [Object]$AssetTypeID,

        [Parameter(Mandatory=$false,
            Position=2)]
            [String]$AssetState,

        [Parameter(Mandatory=$false,
            Position=3)]
            [String]$SerialNumber,

        [Parameter(Mandatory=$false,
            Position=4)]
            [String]$ID,

        [Parameter(Mandatory=$false)]
            [switch]$TypeFields
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
        $APIEndpoint = "$($APIURL)/assets"
        $pagination = $true
        $PrimaryObject = 'assets'
    } Process {
        
        # If any parameters are passed, get assets that match the parameters
        if ($Name -or $AssetTypeID -or $AssetState -or $SerialNumber) {
            if ($Name -or $AssetTypeID -or $AssetState) {
            $APIEndpoint += "?filter=`""
            if ($Name) {$APIEndpoint += "name:'$($Name)' AND "}
            if ($AssetTypeID) {$APIEndpoint += "asset_type_id:$($AssetTypeID) AND "}
            if ($AssetState) {$APIEndpoint += "asset_state:'$($AssetState)' AND "}
            $APIEndpoint = $APIEndpoint -replace "\s.{3}\s$","`""
            if ($SerialNumber) {$APIEndpoint += "&search=`"serial_number:$($SerialNumber)"}
        }
            if ($SerialNumber) {$APIEndpoint += "search=`"serial_number:$($SerialNumber)"}
            Write-Verbose "so far after params and regex: $($APIEndpoint)"
        }
        # If an ID is passed, get that asset
        elseif ($ID) {
            $APIEndpoint += "/$($ID)"
            Write-Verbose "so far after params and regex: $($APIEndpoint)"
            $pagination = $false
            $PrimaryObject = 'asset'
        }
        # if TypeFields is true, include type_fields in the API call
        if ($TypeFields) {
            Write-Verbose "Including type_fields in API call..."
            $APIEndpoint += "?include=type_fields"
        }
        Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject $PrimaryObject -Paginate $pagination -Method 'Get'
    } End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
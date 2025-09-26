Function New-FsProduct {
<#
.SYNOPSIS
    Creates a Product within FreshService
.DESCRIPTION
    The New-FsProduct function inputs a new Product into the FreshService domain
    *REQUIRED PARAMS* - Name & AssetTypeID
.EXAMPLE
    New-FsProduct -Name 'Intel' -AssetTypeID $AssetTypeID
.PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
    [CmdletBinding()] #Enable all the default paramters, including
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            Position=0)]
            [String]$Name,
        
        [Parameter(Mandatory=$true,
            Position=1)]
            [int64]$AssetTypeID,

        [Parameter(Mandatory=$false,
            Position=2)]
            [String]$status,

        [Parameter(Mandatory=$false)]
            [string]$Manufacturer
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
    }
    Process{

        $Attributes = @{}
        $Attributes.Add('name', $($Name))
        $Attributes.Add('asset_type_id', $($AssetTypeID))
        if ($status){ $Attributes.Add('status', $($status))}
        if ($Manufacturer){ $Attributes.Add('manufacturer', $($Manufacturer))}

        $Body = $Attributes | ConvertTo-Json
        write-verbose "Body: $Body"

        Get-FreshServiceAPIResult -APIEndpoint "$($APIURL)/products" -Body $Body -Method 'POST'
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
Function New-FsAssetType {
<#
.SYNOPSIS
    Creates an asset type within FreshService
.DESCRIPTION
    The New-FsAssetType function inputs a new asset tpye into the FreshService domain
    *REQUIRED PARAMS* - Name
.EXAMPLE
    New-FsAssetType -Name 'Printers' -Description 'printers for printing' . . . 
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
        
        [Parameter(Mandatory=$false,
            Position=1)]
            [String]$Description,
        
        [Parameter(Mandatory=$false,
            Position=2)]
            [Object]$ParentType
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
        if (!($TimeFormat)) {
            $TimeFormat = '12h'
        }
        if (!($TimeZone)) {
            $TimeZone = 'Pacific Time (US & Canada)'
        }
    }
    Process{

        $TypesHT = @{}
        $Types = Get-FsAssetType
        foreach ($Type in $Types) {
            if ($Type.id -and $Type.name) {
                $TypesHT[$Type.name] = $Type.id
            }
        }
        $ParentType = $($TypesHT["$ParentType"])
        Write-Verbose "Asset type: $ParentType"

        $Attributes = @{}
        if ($Name){
            $Attributes.Add('name', $($Name))
        }
        if ($Description){
            $Attributes.Add('description', $($Description))
        }
        if ($ParentType){
            $Attributes.Add('parent_asset_type_id', $($ParentType))
        }

        $Body = $Attributes | ConvertTo-Json

        Invoke-WebRequest -Uri "$($APIURL)/asset_types" -Headers $headers -Body $Body -Method Post
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
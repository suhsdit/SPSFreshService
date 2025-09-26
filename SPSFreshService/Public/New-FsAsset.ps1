Function New-FsAsset {
<#
.SYNOPSIS
    Creates an asset within FreshService
.DESCRIPTION
    The New-FsAsset function inputs a new asset into the FreshService domain
    *REQUIRED PARAMS* - Name, AssetType
    -- Making a new asset with parent asset type of Hardware is not working -- 
.EXAMPLE
    New-FsAsset -Name 'DOD666STA' -AssetType 'Computer' . . . 
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
            [Int64]$AssetTypeID,

        [Parameter(Mandatory=$false)]
            [Int64]$ProductID,
            
        [Parameter(Mandatory=$false)]
            [String]$AssetState,
        
        [Parameter(Mandatory=$false)]
            [Int]$DisplayID,
        
        [Parameter(Mandatory=$false,
            Position=3)]
            [String]$Description,
        
        [Parameter(Mandatory=$false)]
            [String]$AssetTag,
        
        [Parameter(Mandatory=$false)]
            [String]$Impact,
        
        [Parameter(Mandatory=$false)]
            [String]$UsageType,
        
        [Parameter(Mandatory=$false)]
            [Int]$UserID,
        
        [Parameter(Mandatory=$false)]
            [Int]$LocationID,
        
        [Parameter(Mandatory=$false)]
            [Int64]$DeptID,
        
        [Parameter(Mandatory=$false)]
            [Int]$GroupID,
        
        [Parameter(Mandatory=$false)]
            [Int]$AgentID,
        
        [Parameter(Mandatory=$false)]
            [DateTime]$AssignedOn,

        [Parameter(Mandatory=$false)]
            [hashtable]$TypeFields = @{}
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
        $Attributes = @{}
        if ($Name) { $Attributes.Add('name', $Name) }
        if ($DisplayID) { $Attributes.Add('display_id', $DisplayID) }
        if ($Description) { $Attributes.Add('description', $Description) }
        if ($AssetTypeID) { $Attributes.Add('asset_type_id', $AssetTypeID) }
        if ($AssetTag) { $Attributes.Add('asset_tag', $AssetTag) }
        if ($Impact) { $Attributes.Add('impact', $Impact) }
        if ($UsageType) { $Attributes.Add('usage_type', $UsageType) }
        if ($UserID) { $Attributes.Add('user_id', $UserID) }
        if ($LocationID) { $Attributes.Add('location_id', $LocationID) }
        if ($DeptID) { $Attributes.Add('department_id', $DeptID) }
        if ($AgentID) { $Attributes.Add('agent_id', $AgentID) }
        if ($GroupID) { $Attributes.Add('group_id', $GroupID) }
        if ($AssignedOn) { $Attributes.Add('assigned_on', $AssignedOn) }
        
        # This number is the AssetType ID, an asset will have an AssetTypeID for every asset type it is a child of
        # There has to be a more efficient way to design this, but I can't think what that may be right now.
        # The below logic will assume an AssetType of Hardware if it is not already defined in the TypeFields hashtable
        # For reference:
        # Hardware = 12345001
        # Computer = 12345002
        # Chromebook = 12345003

        # If typefields does not include ProductID, add it
        #if (!($TypeFields.ContainsKey("product_12345001"))) {
        #    $TypeFields.Add("product_12345001", $ProductID)
        #}
        # If typefields does not include AssetState, add it
        #if (!($TypeFields.ContainsKey("asset_state_12345001"))) {
        #    $TypeFields.Add("asset_state_12345001", $AssetState)
        #}

        Write-Verbose "TypeFields is"
        Write-Verbose $TypeFields.GetEnumerator()

        $Attributes.Add('type_fields', $TypeFields)
        Write-Verbose -Message "Attributes is $($Attributes)"

        
        $Body = $Attributes | ConvertTo-Json
        Write-Verbose -Message "Body is $($Body)"

        Invoke-WebRequest -Uri "$($APIURL)/assets" -Headers $headers -Body $Body -Method Post
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
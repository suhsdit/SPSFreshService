Function Update-FsAssetType {
<#
.SYNOPSIS
    Updates an asset type within FreshService
.DESCRIPTION
    The Update-FsAssetType function updates an existing asset type in the FreshService domain
    *REQUIRED FIELDS* - UpdateID
.EXAMPLE
    Update-FsAsset -Name 'Printer' -UpdateID '12345678' . . .
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
            Position=0)]
            [String]$Name,
        
        [Parameter(Mandatory=$false,
            Position=1)]
            [String]$Description,
        
        [Parameter(Mandatory=$false,
            Position=2)]
            [Boolean]$Visible,

        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            Position=11)]
            [String]$UpdateID
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
    }
    Process{
        
        $Attributes = @{}
        if ($Name){
            $Attributes.Add('name', $($Name))
        }
        if ($ID){
            $Attributes.Add('id', $($LastName))
        }
        if ($DisplayID){
            $Attributes.Add('display_id', $($DisplayID))
        }
        if ($Description){
            $Attributes.Add('description', $($Description))
        }
        if ($AssetType){
            $Attributes.Add('asset_type', $($AssetType))
        }
        if ($AssetTag){
            $Attributes.Add('asset_tag', $($AssetTag))
        }
        if ($Impact){
            $Attributes.Add('impact', $($Impact))
        }
        if ($AuthorType){
            $Attributes.Add('author_type', $($AuthorType))
        }
        if ($UsageType){
            $Attributes.Add('usage_type', $($UsageType))
        }
        if ($UserID){
            $Attributes.Add('user_id', $($UserID))
        }
        if ($LocationID){
            $Attributes.Add('location_id', $($LocationID))
        }
        if ($DeptID){
            $Attributes.Add('dept_id', $($DeptID))
        }
        if ($AgentID){
            $Attributes.Add('agent_id', $($AgentID))
        }
        if ($GroupID){
            $Attributes.Add('group_id', $($GroupID))
        }
        if ($AssignedOn){
            $Attributes.Add('assigned_on', $($AssignedOn))
        }
        if ($CreatedAt){
            $Attributes.Add('created_at', $($CreatedAt))
        }
        if ($UpdatedAt){
            $Attributes.Add('updated_at', $($UpdatedAt))
        }

        $Body = $Attributes | ConvertTo-Json
        
        Invoke-WebRequest -Uri "$($APIURL)/asset_types/$($UpdateID)" -Body $Body -Method 'PUT' -Headers $headers
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
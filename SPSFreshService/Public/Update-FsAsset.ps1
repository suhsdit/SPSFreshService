Function Update-FsAsset {
<#
.SYNOPSIS
    Updates an asset within FreshService
.DESCRIPTION
    The Update-FsAsset function updates an existing asset in the FreshService domain
    *REQUIRED FIELDS* - UpdateID <---- (display_id for assets)
.EXAMPLE
    Update-FsAsset -Name 'HP Printer 1' -UpdateID '12345679' . . .
.PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
    [CmdletBinding()] #Enable all the default paramters, including
    Param(
        [Parameter(Mandatory=$true,
            Position=0)]
            [Int]$ID,

        [Parameter(Mandatory=$false,
            ValueFromPipeline=$true,
            Position=1)]
            [String]$Name,
        
        [Parameter(Mandatory=$false,
            Position=2)]
            [Int]$DisplayID,
        
        [Parameter(Mandatory=$false,
            Position=3)]
            [String]$Description,
        
        [Parameter(Mandatory=$false,
            Position=4)]
            [int64]$AssetTypeID,
        
        [Parameter(Mandatory=$false,
            Position=6)]
            [String]$AssetTag,
        
        [Parameter(Mandatory=$false,
            Position=7)]
            [String]$Impact,
        
        [Parameter(Mandatory=$false,
            Position=8)]
            [String]$AuthorType,
        
        [Parameter(Mandatory=$false,
            Position=10)]
            [String]$UsageType,
        
        [Parameter(Mandatory=$false,
            Position=11)]
            [Int]$UserID,
        
        [Parameter(Mandatory=$false,
            Position=12)]
            [Int]$LocationID,
        
        [Parameter(Mandatory=$false,
            Position=13)]
            [Int]$DeptID,
        
        [Parameter(Mandatory=$false,
            Position=14)]
            [Int]$GroupID,
        
        [Parameter(Mandatory=$false,
            Position=15)]
            [Int]$AgentID,
        
        [Parameter(Mandatory=$false,
            Position=16)]
            [DateTime]$AssignedOn,

        [Parameter(Mandatory=$false,
            Position=17)]
            [DateTime]$CreatedAt,

        [Parameter(Mandatory=$false,
            Position=18)]
            [DateTime]$UpdatedAt,

        [Parameter(Mandatory=$false)]
            [hashtable]$TypeFields = @{}
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
        if ($DisplayID){
            $Attributes.Add('display_id', $($DisplayID))
        }
        if ($Description){
            $Attributes.Add('description', $($Description))
        }
        if ($AssetTypeID){
            $Attributes.Add('asset_type', $($AssetTypeID))
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
        if ($TypeFields){
            $Attributes.Add('type_fields', $($TypeFields))
        }

        $Body = $Attributes | ConvertTo-Json
        
        Invoke-WebRequest -Uri "$($APIURL)/assets/$($ID)" -Body $Body -Method 'PUT' -Headers $headers
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
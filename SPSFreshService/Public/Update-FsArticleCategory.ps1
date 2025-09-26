Function Update-FsArticleCategory {
<#
.SYNOPSIS
    Updates a Solution Article Category in FreshService
.DESCRIPTION
    The Update-FsArticleCategory function updates an existing solution article category in your FreshService domain.
    You can modify the name, description, visibility, and workspace.
.EXAMPLE
    Update-FsArticleCategory -ID 123 -Name "Hardware & Equipment Issues"
    Updates the name of category 123
.EXAMPLE
    Update-FsArticleCategory -ID 123 -Description "All hardware related problems and equipment issues" -Visibility "agents_only"
    Updates the description and visibility of category 123
.PARAMETER ID
    The ID of the category to update (required)
.PARAMETER Name
    The new name of the category
.PARAMETER Description
    The new description of the category
.PARAMETER Visibility
    The new visibility level of the category. Valid values: all_users, logged_in_users, agents_only
.PARAMETER WorkspaceID
    The ID of the workspace where the category should be moved
.INPUTS
    [Int64] - ID can be passed via pipeline
    [PSCustomObject] - Category properties can be passed via pipeline
.OUTPUTS
    [PSCustomObject] - Returns the updated category object from FreshService
.NOTES
    Requires FreshService API authentication with appropriate permissions
.LINK
    https://api.freshservice.com/v2/#update_solution_category
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
            [Int64]$ID,
            
        [Parameter(Mandatory=$false)]
            [string]$Name,
            
        [Parameter(Mandatory=$false)]
            [string]$Description,
            
        [Parameter(Mandatory=$false)]
            [ValidateSet('all_users', 'logged_in_users', 'agents_only')]
            [string]$Visibility,
            
        [Parameter(Mandatory=$false)]
            [Int64]$WorkspaceID
    )
    
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName)..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
    } 
    
    Process {
        $APIEndpoint = "$($Script:APIURL)/solutions/categories/$($ID)"
        Write-Verbose "API Endpoint: $($APIEndpoint)"
        
        # Build the request body with only provided parameters
        $RequestBody = @{}
        
        if ($Name) {
            $RequestBody.name = $Name
        }
        
        if ($Description) {
            $RequestBody.description = $Description
        }
        
        if ($Visibility) {
            $RequestBody.visibility = $Visibility
        }
        
        if ($WorkspaceID) {
            $RequestBody.workspace_id = $WorkspaceID
        }
        
        # Check if we have at least one parameter to update
        if ($RequestBody.Count -eq 0) {
            Write-Warning "No parameters provided for update. Nothing to change."
            return
        }
        
        Write-Verbose "Request Body: $($RequestBody | ConvertTo-Json -Depth 10)"
        
        # Make the API call
        $APIParams = @{
            APIEndpoint = $APIEndpoint
            PrimaryObject = 'category'
            Paginate = $false
            Method = 'PUT'
            RequestBody = $RequestBody
        }
        
        Get-FreshServiceAPIResult @APIParams
    } 
    
    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}

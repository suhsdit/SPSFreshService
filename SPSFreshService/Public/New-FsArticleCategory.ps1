Function New-FsArticleCategory {
<#
.SYNOPSIS
    Creates a new Solution Article Category in FreshService
.DESCRIPTION
    The New-FsArticleCategory function creates a new solution article category in your FreshService domain.
    You can specify the name, description, visibility, and workspace.
.EXAMPLE
    New-FsArticleCategory -Name "Hardware Issues" -Description "Hardware related problems"
    Creates a new category with the specified name and description
.EXAMPLE
    New-FsArticleCategory -Name "Software Issues" -Description "Software related problems" -Visibility "agents_only" -WorkspaceID 2
    Creates a new category with agents-only visibility in a specific workspace
.PARAMETER Name
    The name of the category (required)
.PARAMETER Description
    A description of the category
.PARAMETER Visibility
    The visibility level of the category. Valid values: all_users, logged_in_users, agents_only
.PARAMETER WorkspaceID
    The ID of the workspace where the category should be created
.INPUTS
    [PSCustomObject] - Category properties can be passed via pipeline
.OUTPUTS
    [PSCustomObject] - Returns the created category object from FreshService
.NOTES
    Requires FreshService API authentication with appropriate permissions
.LINK
    https://api.freshservice.com/v2/#create_solution_category
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
            Position=0)]
            [string]$Name,
            
        [Parameter(Mandatory=$false,
            Position=1)]
            [string]$Description,
            
        [Parameter(Mandatory=$false)]
            [ValidateSet('all_users', 'logged_in_users', 'agents_only')]
            [string]$Visibility = 'all_users',
            
        [Parameter(Mandatory=$false)]
            [Int64]$WorkspaceID
    )
    
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName)..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
    } 
    
    Process {
        $APIEndpoint = "$($Script:APIURL)/solutions/categories"
        Write-Verbose "API Endpoint: $($APIEndpoint)"
        
        # Build the request body
        $RequestBody = @{
            name = $Name
            description = $Description
            visibility = $Visibility
        }
        
        # Add workspace_id if specified
        if ($WorkspaceID) {
            $RequestBody.workspace_id = $WorkspaceID
        }
        
        # Remove empty values
        $RequestBody = $RequestBody | Where-Object { $null -ne $_.Value -and $_.Value -ne '' }
        
        Write-Verbose "Request Body: $($RequestBody | ConvertTo-Json -Depth 10)"
        
        # Make the API call
        $APIParams = @{
            APIEndpoint = $APIEndpoint
            PrimaryObject = 'category'
            Paginate = $false
            Method = 'POST'
            RequestBody = $RequestBody
        }
        
        Get-FreshServiceAPIResult @APIParams
    } 
    
    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}

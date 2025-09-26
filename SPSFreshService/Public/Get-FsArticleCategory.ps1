Function Get-FsArticleCategory {
<#
.SYNOPSIS
    Gets Solution Article Categories from FreshService
.DESCRIPTION
    The Get-FsCategory function retrieves solution categories from your FreshService domain.
    You can get all categories or a specific category by ID.
.EXAMPLE
    Get-FsCategory
    Gets all solution categories
.EXAMPLE
    Get-FsCategory -ID 123
    Gets the category with ID 123
.PARAMETER ID
    The ID of a specific category to retrieve
.PARAMETER WorkspaceID
    The workspace ID to get categories from (optional)
.INPUTS
    [Int64] - ID can be passed via pipeline
.OUTPUTS
    [PSCustomObject] - Returns category objects from FreshService
.NOTES
    Requires FreshService API authentication
.LINK
    https://api.freshservice.com/v2/#view_solution_category
#>
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [Parameter(Mandatory=$false,
            ParameterSetName='ByID',
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
            [Int64]$ID,
            
        [Parameter(Mandatory=$false)]
            [Int32]$WorkspaceID
    )
    
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
    } 
    
    Process {
        if ($ID) {
            # Get specific category by ID
            $APIEndpoint = "$($Script:APIURL)/solutions/categories/$($ID)"
            Write-Verbose "API Endpoint: $($APIEndpoint)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'category' -Paginate $false -Method 'GET'
        }
        else {
            # Get all categories
            $APIEndpoint = "$($Script:APIURL)/solutions/categories"
            
            if ($WorkspaceID) {
                $APIEndpoint += "?workspace_id=$($WorkspaceID)"
            }
            
            Write-Verbose "API Endpoint: $($APIEndpoint)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'categories' -Paginate $true -Method 'GET'
        } 
    } 
    
    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}

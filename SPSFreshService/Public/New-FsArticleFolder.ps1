Function New-FsArticleFolder {
<#
.SYNOPSIS
    Creates a new Solution Article Folder in FreshService
.DESCRIPTION
    The New-FsArticleFolder function creates a new solution article folder in your FreshService domain.
    You can specify the name, description, visibility, category, and parent folder.
.EXAMPLE
    New-FsArticleFolder -Name "Windows Issues" -CategoryID 123
    Creates a new folder in category 123
.EXAMPLE
    New-FsArticleFolder -Name "Office Applications" -CategoryID 123 -ParentID 456 -Description "Microsoft Office related issues"
    Creates a new sub-folder under folder 456 in category 123
.PARAMETER Name
    The name of the folder (required)
.PARAMETER CategoryID
    The ID of the category where the folder should be created (required)
.PARAMETER ParentID
    The ID of the parent folder (optional, for creating sub-folders)
.PARAMETER Description
    A description of the folder
.PARAMETER Visibility
    The visibility level of the folder. Valid values: all_users, logged_in_users, agents_only
.INPUTS
    [PSCustomObject] - Folder properties can be passed via pipeline
.OUTPUTS
    [PSCustomObject] - Returns the created folder object from FreshService
.NOTES
    Requires FreshService API authentication with appropriate permissions
.LINK
    https://api.freshservice.com/v2/#create_solution_folder
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
            Position=0)]
            [string]$Name,
            
        [Parameter(Mandatory=$true,
            Position=1)]
            [Int64]$CategoryID,
            
        [Parameter(Mandatory=$false)]
            [Int64]$ParentID,
            
        [Parameter(Mandatory=$false)]
            [string]$Description,
            
        [Parameter(Mandatory=$false)]
            [ValidateSet('all_users', 'logged_in_users', 'agents_only')]
            [string]$Visibility = 'all_users'
    )
    
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName)..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
    } 
    
    Process {
        $APIEndpoint = "$($Script:APIURL)/solutions/folders"
        Write-Verbose "API Endpoint: $($APIEndpoint)"
        
        # Build the request body
        $RequestBody = @{
            name = $Name
            category_id = $CategoryID
            description = $Description
            visibility = $Visibility
        }
        
        # Add parent_id if specified
        if ($ParentID) {
            $RequestBody.parent_id = $ParentID
        }
        
        # Remove empty values
        $RequestBody = $RequestBody | Where-Object { $null -ne $_.Value -and $_.Value -ne '' }
        
        Write-Verbose "Request Body: $($RequestBody | ConvertTo-Json -Depth 10)"
        
        # Make the API call
        $APIParams = @{
            APIEndpoint = $APIEndpoint
            PrimaryObject = 'folder'
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

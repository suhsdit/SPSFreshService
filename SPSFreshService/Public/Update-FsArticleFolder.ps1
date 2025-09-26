Function Update-FsArticleFolder {
<#
.SYNOPSIS
    Updates a Solution Article Folder in FreshService
.DESCRIPTION
    The Update-FsArticleFolder function updates an existing solution article folder in your FreshService domain.
    You can modify the name, description, visibility, category, and parent folder.
.EXAMPLE
    Update-FsArticleFolder -ID 456 -Name "Windows 10/11 Issues"
    Updates the name of folder 456
.EXAMPLE
    Update-FsArticleFolder -ID 456 -Description "Windows 10 and 11 related issues" -Visibility "agents_only"
    Updates the description and visibility of folder 456
.EXAMPLE
    Update-FsArticleFolder -ID 456 -ParentID 789
    Moves folder 456 under parent folder 789
.PARAMETER ID
    The ID of the folder to update (required)
.PARAMETER Name
    The new name of the folder
.PARAMETER Description
    The new description of the folder
.PARAMETER Visibility
    The new visibility level of the folder. Valid values: all_users, logged_in_users, agents_only
.PARAMETER CategoryID
    The ID of the category where the folder should be moved
.PARAMETER ParentID
    The ID of the new parent folder (use 0 to make it a root folder)
.INPUTS
    [Int64] - ID can be passed via pipeline
    [PSCustomObject] - Folder properties can be passed via pipeline
.OUTPUTS
    [PSCustomObject] - Returns the updated folder object from FreshService
.NOTES
    Requires FreshService API authentication with appropriate permissions
.LINK
    https://api.freshservice.com/v2/#update_solution_folder
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
            [Int64]$CategoryID,
            
        [Parameter(Mandatory=$false)]
            [Int64]$ParentID
    )
    
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName)..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
    } 
    
    Process {
        $APIEndpoint = "$($Script:APIURL)/solutions/folders/$($ID)"
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
        
        if ($CategoryID) {
            $RequestBody.category_id = $CategoryID
        }
        
        if ($PSBoundParameters.ContainsKey('ParentID')) {
            # Allow setting ParentID to 0 to make it a root folder
            $RequestBody.parent_id = $ParentID
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
            PrimaryObject = 'folder'
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

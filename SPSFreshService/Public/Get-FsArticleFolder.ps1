Function Get-FsArticleFolder {
<#
.SYNOPSIS
    Gets Solution Article Folders from FreshService
.DESCRIPTION
    The Get-FsArticleFolder function retrieves solution article folders from your FreshService domain.
    You can get all folders in a category, get a specific folder by ID, get sub-folders, or get all folders across all categories.
.EXAMPLE
    Get-FsArticleFolder -CategoryID 123
    Gets all folders in category 123
.EXAMPLE
    Get-FsArticleFolder -ID 456
    Gets the folder with ID 456
.EXAMPLE
    Get-FsArticleFolder -ParentID 456
    Gets all sub-folders under folder 456
.EXAMPLE
    Get-FsArticleFolder -All
    Gets all folders from all categories
.PARAMETER CategoryID
    The ID of the category to retrieve folders from
.PARAMETER ID
    The ID of a specific folder to retrieve
.PARAMETER ParentID
    The ID of the parent folder to retrieve sub-folders from
.PARAMETER All
    Switch to retrieve all folders from all categories
.INPUTS
    [Int64] - ID can be passed via pipeline
.OUTPUTS
    [PSCustomObject] - Returns folder objects from FreshService
.NOTES
    Requires FreshService API authentication
.LINK
    https://api.freshservice.com/v2/#view_solution_folder
#>
    [CmdletBinding(DefaultParameterSetName='ByCategory')]
    Param(
        [Parameter(Mandatory=$true,
            ParameterSetName='ByCategory',
            Position=0)]
            [Int64]$CategoryID,
            
        [Parameter(Mandatory=$true,
            ParameterSetName='ByID',
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
            [Int64]$ID,
            
        [Parameter(Mandatory=$true,
            ParameterSetName='ByParent',
            Position=0)]
            [Int64]$ParentID,
            
        [Parameter(Mandatory=$false,
            ParameterSetName='All')]
            [switch]$All
    )
    
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
    } 
    
    Process {
        if ($All) {
            # Get all folders across all categories
            Write-Verbose "Getting all folders from all categories..."
            $categories = Get-FsArticleCategory
            foreach ($category in $categories) {
                Write-Verbose "Getting folders for category: $($category.name) (ID: $($category.id))"
                $folders = Get-FsArticleFolder -CategoryID $category.id
                foreach ($folder in $folders) {
                    # Add category information to each folder
                    $folder | Add-Member -NotePropertyName 'CategoryName' -NotePropertyValue $category.name -Force
                    $folder | Add-Member -NotePropertyName 'CategoryID' -NotePropertyValue $category.id -Force
                    $folder
                }
            }
        }
        elseif ($ID) {
            # Get specific folder by ID
            $APIEndpoint = "$($Script:APIURL)/solutions/folders/$($ID)"
            Write-Verbose "API Endpoint: $($APIEndpoint)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'folder' -Paginate $false -Method 'GET'
        }
        elseif ($ParentID) {
            # Get sub-folders
            $APIEndpoint = "$($Script:APIURL)/solutions/folders/$($ParentID)/sub-folders"
            Write-Verbose "API Endpoint: $($APIEndpoint)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'folders' -Paginate $true -Method 'GET'
        }
        else {
            # Get all folders in category
            $APIEndpoint = "$($Script:APIURL)/solutions/folders?category_id=$($CategoryID)"
            Write-Verbose "API Endpoint: $($APIEndpoint)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'folders' -Paginate $true -Method 'GET'
        } 
    } 
    
    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}

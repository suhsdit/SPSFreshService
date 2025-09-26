Function Get-FsArticle {
<#
.SYNOPSIS
    Gets one or more Solution Articles from FreshService
.DESCRIPTION
    The Get-FsArticle function gets solution articles from your FreshService domain.
    To get articles from a specific folder, use -FolderID. To get a specific article, use -ID.
    To get all articles from all folders and categories, use -All.
    To search across all articles, use Search-FsArticle instead.
.EXAMPLE
    Get-FsArticle -FolderID 2
    Get all articles in folder ID 2
.EXAMPLE
    Get-FsArticle -ID 1
    Get a specific article by ID
.EXAMPLE
    Get-FsArticle -All
    Get all articles from all folders in all categories
.EXAMPLE
    Search-FsArticle -SearchTerm "password"
    Search for articles containing "password" across all folders
.PARAMETER FolderID
    The folder ID to retrieve articles from
.PARAMETER ID
    The specific article ID to retrieve
.PARAMETER All
    Switch to retrieve all articles from all folders in all categories
.PARAMETER Pages
    Maximum number of pages to retrieve (default: 10000)
.INPUTS
    String
.OUTPUTS
    PSCustomObject
.NOTES
    Requires FreshService API connection. The FreshService API requires either a FolderID or specific ID.
    Use -All to get all articles from all folders and categories.
    To search across all articles without specifying a folder, use Search-FsArticle.
.LINK
    https://api.freshservice.com/v2/#view_solution_article
#>
    [CmdletBinding()] 
    Param(
        [Parameter(Mandatory=$false,
            ParameterSetName='ByFolder',
            Position=0)]
            [String]$FolderID,
        
        [Parameter(Mandatory=$false,
            ParameterSetName='ByID',
            ValueFromPipeline=$true,
            Position=0)]
            [String]$ID,
        
        [Parameter(Mandatory=$false,
            ParameterSetName='All')]
            [switch]$All,
        
        [Parameter(Mandatory=$false)]
            [Int32]$Pages = 10000
    )
    
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
    } 
    
    Process {
        if ($All) {
            # Get all articles from all folders in all categories
            Write-Verbose "Getting ALL articles from all categories and folders..."
            
            try {
                # Get all categories
                Write-Verbose "Retrieving all solution categories..."
                $categories = Get-FsCategory
                
                foreach ($category in $categories) {
                    Write-Verbose "Processing category: $($category.name) (ID: $($category.id))"
                    
                    # Get all folders in this category
                    $folders = Get-FsFolder -CategoryID $category.id
                    
                    foreach ($folder in $folders) {
                        Write-Verbose "Getting articles from folder: $($folder.name) (ID: $($folder.id))"
                        
                        # Get articles in this folder
                        $articles = Get-FsArticle -FolderID $folder.id -Pages $Pages
                        
                        # Output articles with additional context
                        foreach ($article in $articles) {
                            $article | Add-Member -NotePropertyName 'CategoryName' -NotePropertyValue $category.name -Force
                            $article | Add-Member -NotePropertyName 'CategoryID' -NotePropertyValue $category.id -Force
                            $article | Add-Member -NotePropertyName 'FolderName' -NotePropertyValue $folder.name -Force
                            $article | Add-Member -NotePropertyName 'FolderID' -NotePropertyValue $folder.id -Force
                            $article
                        }
                    }
                }
            }
            catch {
                Write-Error "Failed to retrieve all articles: $_"
            }
        }
        elseif ($ID) {
            # Get specific article by ID
            $APIEndpoint = "$($Script:APIURL)/solutions/articles/$($ID)"
            Write-Verbose "API Endpoint: $($APIEndpoint)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'article' -Paginate $false -Method 'GET'
        }
        elseif ($FolderID) {
            # Get articles from specific folder
            $APIEndpoint = "$($Script:APIURL)/solutions/articles?folder_id=$($FolderID)"
            Write-Verbose "API Endpoint: $($APIEndpoint)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'articles' -Paginate $true -Pages $Pages -Method 'GET'
        }
        else {
            Write-Warning "Get-FsArticle requires either -FolderID, -ID, or -All parameter. To search all articles, use Search-FsArticle instead."
            Write-Host "Examples:" -ForegroundColor Yellow
            Write-Host "  Get-FsArticle -FolderID 123" -ForegroundColor Green
            Write-Host "  Get-FsArticle -ID 456" -ForegroundColor Green  
            Write-Host "  Get-FsArticle -All" -ForegroundColor Green
            Write-Host "  Search-FsArticle -SearchTerm 'password'" -ForegroundColor Green
            return
        } 
    } 
    
    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}

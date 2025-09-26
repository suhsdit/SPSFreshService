Function Import-FsKnowledgeBase {
<#
.SYNOPSIS
    Imports changes from FreshService to the local knowledge base repository
.DESCRIPTION
    The Import-FsKnowledgeBase function retrieves the latest content from FreshService
    and updates local HTML and JSON files. This is useful for pulling changes made
    directly in FreshService back to your git repository.
.EXAMPLE
    Import-FsKnowledgeBase -OutputPath "C:\MyRepo\Articles"
    Imports all changes from FreshService to the local repository
.EXAMPLE
    Import-FsKnowledgeBase -OutputPath "C:\MyRepo\Articles" -ArticleID 123
    Imports only the specified article
.PARAMETER OutputPath
    The local folder path containing the knowledge base files
.PARAMETER ArticleID
    Optional: Import only a specific article
.PARAMETER CategoryID
    Optional: Import only articles from a specific category
.PARAMETER Force
    Overwrites local files even if they appear newer than FreshService
.INPUTS
    None
.OUTPUTS
    [PSCustomObject] - Returns import summary with counts of items updated
.NOTES
    Requires FreshService API authentication
    Expects existing folder structure created by Export-FsKnowledgeBase
.LINK
    https://api.freshservice.com/v2/#solution_articles
#>
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory=$true,
            Position=0)]
            [string]$OutputPath,
            
        [Parameter(Mandatory=$false)]
            [Int64]$ArticleID,
            
        [Parameter(Mandatory=$false)]
            [Int64]$CategoryID,
            
        [Parameter(Mandatory=$false)]
            [switch]$Force
    )
    
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName)..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
        
        # Initialize counters
        $importSummary = @{
            CategoriesProcessed = 0
            FoldersProcessed = 0
            ArticlesUpdated = 0
            ArticlesSkipped = 0
            Errors = @()
            StartTime = Get-Date
        }
    } 
    
    Process {
        try {
            if (-not (Test-Path $OutputPath)) {
                throw "Output path does not exist: $OutputPath. Run Export-FsKnowledgeBase first to create the initial structure."
            }
            
            if ($ArticleID) {
                # Import specific article
                Write-Host "Importing specific article ID: $ArticleID" -ForegroundColor Green
                
                try {
                    $article = Get-FsArticle -ID $ArticleID
                    $result = Import-SingleArticle -Article $article -OutputPath $OutputPath -Force:$Force
                    if ($result) {
                        $importSummary.ArticlesUpdated++
                    } else {
                        $importSummary.ArticlesSkipped++
                    }
                }
                catch {
                    $errorMsg = "Failed to import article ID ${ArticleID}: $_"
                    Write-Warning $errorMsg
                    $importSummary.Errors += $errorMsg
                }
            }
            else {
                # Import all articles or articles from specific category
                if ($CategoryID) {
                    Write-Host "Importing articles from category ID: $CategoryID" -ForegroundColor Green
                    $articles = Get-FsArticle -All | Where-Object { $_.CategoryID -eq $CategoryID }
                }
                else {
                    Write-Host "Importing all articles from FreshService..." -ForegroundColor Green
                    $articles = Get-FsArticle -All
                }
                
                # Group articles by category and folder for organized processing
                $groupedArticles = $articles | Group-Object CategoryID, FolderID
                
                foreach ($group in $groupedArticles) {
                    $categoryID = $group.Group[0].CategoryID
                    $categoryName = $group.Group[0].CategoryName
                    $folderName = $group.Group[0].FolderName
                    
                    Write-Host "Processing Category: $categoryName, Folder: $folderName" -ForegroundColor Yellow
                    $importSummary.FoldersProcessed++
                    
                    foreach ($article in $group.Group) {
                        Write-Host "  Importing article: $($article.title)" -ForegroundColor Cyan
                        
                        try {
                            $result = Import-SingleArticle -Article $article -OutputPath $OutputPath -Force:$Force
                            if ($result) {
                                $importSummary.ArticlesUpdated++
                                Write-Host "    Updated: $($article.title)" -ForegroundColor Green
                            } else {
                                $importSummary.ArticlesSkipped++
                                Write-Verbose "    Skipped: $($article.title) (no changes)"
                            }
                        }
                        catch {
                            $errorMsg = "Failed to import article '$($article.title)' (ID: $($article.id)): $_"
                            Write-Warning $errorMsg
                            $importSummary.Errors += $errorMsg
                        }
                    }
                }
                
                # Count unique categories processed
                $importSummary.CategoriesProcessed = ($articles | Select-Object CategoryID -Unique).Count
            }
            
            # Update final summary
            $importSummary.EndTime = Get-Date
            $importSummary.Duration = $importSummary.EndTime - $importSummary.StartTime
            
            Write-Host "`nImport completed!" -ForegroundColor Green
            Write-Host "Categories processed: $($importSummary.CategoriesProcessed)" -ForegroundColor White
            Write-Host "Folders processed: $($importSummary.FoldersProcessed)" -ForegroundColor White  
            Write-Host "Articles updated: $($importSummary.ArticlesUpdated)" -ForegroundColor White
            Write-Host "Articles skipped: $($importSummary.ArticlesSkipped)" -ForegroundColor White
            Write-Host "Duration: $($importSummary.Duration.ToString('mm\:ss'))" -ForegroundColor White
            
            if ($importSummary.Errors.Count -gt 0) {
                Write-Host "Errors: $($importSummary.Errors.Count)" -ForegroundColor Red
                $importSummary.Errors | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
            }
            
            return [PSCustomObject]$importSummary
        }
        catch {
            Write-Error "Import failed: $_"
            throw
        }
    } 
    
    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}

Function Import-SingleArticle {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Article,
        
        [Parameter(Mandatory=$true)]
        [string]$OutputPath,
        
        [Parameter(Mandatory=$false)]
        [switch]$Force
    )
    
    try {
        # Build the expected file paths
        $categoryFolderName = ConvertTo-SafeFolderName -Name $Article.CategoryName
        $folderName = ConvertTo-SafeFolderName -Name $Article.FolderName
        $articleFileName = ConvertTo-SafeFileName -Name $Article.title
        
        $categoryPath = Join-Path $OutputPath $categoryFolderName
        $folderPath = Join-Path $categoryPath $folderName
        $htmlPath = Join-Path $folderPath "$articleFileName.html"
        $jsonPath = Join-Path $folderPath "$articleFileName.json"
        
        # Ensure directory structure exists
        if (-not (Test-Path $folderPath)) {
            Write-Verbose "Creating folder structure: $folderPath"
            New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
        }
        
        # Check if update is needed
        $needsUpdate = $Force
        if (-not $needsUpdate -and (Test-Path $jsonPath)) {
            try {
                $existingMetadata = Get-Content $jsonPath | ConvertFrom-Json
                $fsModified = [datetime]$Article.updated_at
                $localModified = [datetime]$existingMetadata.updated_at
                $needsUpdate = $fsModified -gt $localModified
            }
            catch {
                Write-Verbose "Could not compare timestamps, forcing update"
                $needsUpdate = $true
            }
        }
        elseif (-not (Test-Path $jsonPath)) {
            $needsUpdate = $true
        }
        
        if ($needsUpdate) {
            # Update HTML content
            if ($Article.description) {
                $Article.description | Out-File -FilePath $htmlPath -Encoding UTF8
                Write-Verbose "Updated HTML content: $htmlPath"
            }
            
            # Update JSON metadata (exclude content and computed properties)
            $articleMetadata = $Article | Select-Object * -ExcludeProperty description, CategoryName, FolderName
            $articleMetadata | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonPath -Encoding UTF8
            Write-Verbose "Updated metadata: $jsonPath"
            
            return $true
        }
        else {
            Write-Verbose "Article is up to date: $($Article.title)"
            return $false
        }
    }
    catch {
        Write-Error "Failed to import article '$($Article.title)': $_"
        throw
    }
}

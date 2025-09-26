Function Sync-FsKnowledgeBase {
<#
.SYNOPSIS
    Synchronizes local knowledge base files to FreshService
.DESCRIPTION
    The Sync-FsKnowledgeBase function compares local HTML and JSON files with FreshService
    and updates FreshService with any changes found in the local repository.
    This is designed to work with the folder structure created by Export-FsKnowledgeBase.
.EXAMPLE
    Sync-FsKnowledgeBase -SourcePath "C:\MyRepo\Articles"
    Syncs all changes from the local repository to FreshService
.EXAMPLE
    Sync-FsKnowledgeBase -SourcePath "C:\MyRepo\Articles" -WhatIf
    Shows what would be synced without making any changes
.PARAMETER SourcePath
    The local folder path containing the knowledge base files
.PARAMETER WhatIf
    Shows what changes would be made without actually making them
.PARAMETER Force
    Forces update of all articles even if timestamps suggest no changes
.INPUTS
    None
.OUTPUTS
    [PSCustomObject] - Returns sync summary with counts of items updated
.NOTES
    Requires FreshService API authentication
    Expects folder structure: Category/Folder/Article.html + Article.json + metadata files
.LINK
    https://api.freshservice.com/v2/#solution_articles
#>
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory=$true,
            Position=0)]
            [string]$SourcePath,
            
        [Parameter(Mandatory=$false)]
            [switch]$Force
    )
    
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName)..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
        
        # Initialize counters
        $syncSummary = @{
            CategoriesProcessed = 0
            FoldersProcessed = 0
            ArticlesUpdated = 0
            ArticlesCreated = 0
            ArticlesSkipped = 0
            Errors = @()
            StartTime = Get-Date
        }
    } 
    
    Process {
        try {
            if (-not (Test-Path $SourcePath)) {
                throw "Source path does not exist: $SourcePath"
            }
            
            # Get all category folders (exclude .freshservice folder)
            $categoryFolders = Get-ChildItem -Path $SourcePath -Directory | Where-Object { $_.Name -ne '.freshservice' }
            
            foreach ($categoryFolder in $categoryFolders) {
                Write-Host "Processing category folder: $($categoryFolder.Name)" -ForegroundColor Green
                $syncSummary.CategoriesProcessed++
                
                # Read category metadata
                $categoryMetadataPath = Join-Path $categoryFolder.FullName ".category.json"
                if (Test-Path $categoryMetadataPath) {
                    $categoryMetadata = Get-Content $categoryMetadataPath | ConvertFrom-Json
                    Write-Verbose "Loaded category metadata: ID $($categoryMetadata.id), Name: $($categoryMetadata.name)"
                } else {
                    Write-Warning "Category metadata file not found: $categoryMetadataPath"
                    continue
                }
                
                # Get all folder directories in this category
                $folderDirectories = Get-ChildItem -Path $categoryFolder.FullName -Directory
                
                foreach ($folderDir in $folderDirectories) {
                    Write-Host "  Processing folder: $($folderDir.Name)" -ForegroundColor Yellow
                    $syncSummary.FoldersProcessed++
                    
                    # Read folder metadata
                    $folderMetadataPath = Join-Path $folderDir.FullName ".folder.json"
                    if (Test-Path $folderMetadataPath) {
                        $folderMetadata = Get-Content $folderMetadataPath | ConvertFrom-Json
                        Write-Verbose "Loaded folder metadata: ID $($folderMetadata.id), Name: $($folderMetadata.name)"
                    } else {
                        Write-Warning "Folder metadata file not found: $folderMetadataPath"
                        continue
                    }
                    
                    # Get all article JSON files in this folder
                    $articleJsonFiles = Get-ChildItem -Path $folderDir.FullName -Filter "*.json" | Where-Object { $_.Name -ne ".folder.json" }
                    
                    foreach ($jsonFile in $articleJsonFiles) {
                        $articleBaseName = [System.IO.Path]::GetFileNameWithoutExtension($jsonFile.Name)
                        $htmlFile = Join-Path $folderDir.FullName "$articleBaseName.html"
                        
                        Write-Host "    Processing article: $articleBaseName" -ForegroundColor Cyan
                        
                        try {
                            # Read article metadata and content
                            $articleMetadata = Get-Content $jsonFile.FullName | ConvertFrom-Json
                            
                            if (Test-Path $htmlFile) {
                                $articleContent = Get-Content $htmlFile -Raw
                            } else {
                                Write-Warning "HTML file not found for article: $htmlFile"
                                $articleContent = ""
                            }
                            
                            # Check if article exists in FreshService
                            if ($articleMetadata.id -and $articleMetadata.id -gt 0) {
                                # Update existing article
                                if ($PSCmdlet.ShouldProcess("Article ID $($articleMetadata.id): $($articleMetadata.title)", "Update FreshService Article")) {
                                    
                                    # Get current article from FreshService to compare
                                    try {
                                        $currentArticle = Get-FsArticle -ID $articleMetadata.id
                                        
                                        # Check if update is needed (compare timestamps or force)
                                        $needsUpdate = $Force
                                        if (-not $needsUpdate) {
                                            $fileModified = (Get-Item $htmlFile -ErrorAction SilentlyContinue).LastWriteTime
                                            $fsModified = [datetime]$currentArticle.updated_at
                                            $needsUpdate = $fileModified -gt $fsModified
                                        }
                                        
                                        if ($needsUpdate) {
                                            Write-Verbose "Updating article ID $($articleMetadata.id)"
                                            
                                            # Update the article
                                            $updateParams = @{
                                                ID = $articleMetadata.id
                                                Title = $articleMetadata.title
                                                Description = $articleContent
                                            }
                                            
                                            # Add optional parameters if present
                                            if ($articleMetadata.status) { $updateParams.Status = $articleMetadata.status }
                                            if ($articleMetadata.keywords) { $updateParams.Keywords = $articleMetadata.keywords }
                                            if ($articleMetadata.tags) { $updateParams.Tags = $articleMetadata.tags }
                                            
                                            Update-FsArticle @updateParams
                                            $syncSummary.ArticlesUpdated++
                                            Write-Host "      Updated article ID $($articleMetadata.id)" -ForegroundColor Green
                                        } else {
                                            Write-Verbose "Article ID $($articleMetadata.id) is up to date, skipping"
                                            $syncSummary.ArticlesSkipped++
                                        }
                                    }
                                    catch {
                                        Write-Warning "Failed to update article ID $($articleMetadata.id): $_"
                                        $syncSummary.Errors += "Update article ID $($articleMetadata.id): $_"
                                    }
                                }
                            } else {
                                # Create new article
                                if ($PSCmdlet.ShouldProcess("New article: $($articleMetadata.title)", "Create FreshService Article")) {
                                    try {
                                        Write-Verbose "Creating new article: $($articleMetadata.title)"
                                        
                                        $createParams = @{
                                            Title = $articleMetadata.title
                                            Description = $articleContent
                                            FolderID = $folderMetadata.id
                                        }
                                        
                                        # Add optional parameters if present
                                        if ($articleMetadata.status) { $createParams.Status = $articleMetadata.status }
                                        if ($articleMetadata.keywords) { $createParams.Keywords = $articleMetadata.keywords }
                                        if ($articleMetadata.tags) { $createParams.Tags = $articleMetadata.tags }
                                        if ($articleMetadata.article_type) { $createParams.ArticleType = $articleMetadata.article_type }
                                        
                                        $newArticle = New-FsArticle @createParams
                                        
                                        # Update the JSON file with the new ID
                                        $articleMetadata.id = $newArticle.id
                                        $articleMetadata.created_at = $newArticle.created_at
                                        $articleMetadata.updated_at = $newArticle.updated_at
                                        
                                        $articleMetadata | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonFile.FullName -Encoding UTF8
                                        
                                        $syncSummary.ArticlesCreated++
                                        Write-Host "      Created article ID $($newArticle.id)" -ForegroundColor Green
                                    }
                                    catch {
                                        Write-Warning "Failed to create article '$($articleMetadata.title)': $_"
                                        $syncSummary.Errors += "Create article '$($articleMetadata.title)': $_"
                                    }
                                }
                            }
                        }
                        catch {
                            Write-Warning "Failed to process article file '$($jsonFile.Name)': $_"
                            $syncSummary.Errors += "Process article '$($jsonFile.Name)': $_"
                        }
                    }
                }
            }
            
            # Update final summary
            $syncSummary.EndTime = Get-Date
            $syncSummary.Duration = $syncSummary.EndTime - $syncSummary.StartTime
            
            Write-Host "`nSync completed!" -ForegroundColor Green
            Write-Host "Categories processed: $($syncSummary.CategoriesProcessed)" -ForegroundColor White
            Write-Host "Folders processed: $($syncSummary.FoldersProcessed)" -ForegroundColor White  
            Write-Host "Articles created: $($syncSummary.ArticlesCreated)" -ForegroundColor White
            Write-Host "Articles updated: $($syncSummary.ArticlesUpdated)" -ForegroundColor White
            Write-Host "Articles skipped: $($syncSummary.ArticlesSkipped)" -ForegroundColor White
            Write-Host "Duration: $($syncSummary.Duration.ToString('mm\:ss'))" -ForegroundColor White
            
            if ($syncSummary.Errors.Count -gt 0) {
                Write-Host "Errors: $($syncSummary.Errors.Count)" -ForegroundColor Red
                $syncSummary.Errors | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
            }
            
            return [PSCustomObject]$syncSummary
        }
        catch {
            Write-Error "Sync failed: $_"
            throw
        }
    } 
    
    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}

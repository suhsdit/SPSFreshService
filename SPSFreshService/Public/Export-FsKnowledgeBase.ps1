Function Export-FsKnowledgeBase {
<#
.SYNOPSIS
    Exports the complete FreshService knowledge base to a local folder structure
.DESCRIPTION
    The Export-FsKnowledgeBase function exports all categories, folders, and articles from your FreshService domain
    to a structured folder hierarchy with separate HTML content files and JSON metadata files.
    This creates a git-friendly representation of your knowledge base.
.EXAMPLE
    Export-FsKnowledgeBase -OutputPath "C:\MyRepo\Articles"
    Exports the entire knowledge base to the specified folder
.EXAMPLE
    Export-FsKnowledgeBase -OutputPath "C:\MyRepo\Articles" -CategoryID 123
    Exports only the specified category and its contents
.PARAMETER OutputPath
    The local folder path where the knowledge base should be exported
.PARAMETER CategoryID
    Optional: Export only a specific category (exports all categories if not specified)
.PARAMETER Force
    Overwrites existing files without prompting
.INPUTS
    None
.OUTPUTS
    [PSCustomObject] - Returns export summary with counts of categories, folders, and articles exported
.NOTES
    Requires FreshService API authentication
    Creates folder structure: Category/Folder/Article.html + Article.json + metadata files
.LINK
    https://api.freshservice.com/v2/#solution_articles
#>
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory=$true,
            Position=0)]
            [string]$OutputPath,
            
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
        $exportSummary = @{
            CategoriesExported = 0
            FoldersExported = 0
            ArticlesExported = 0
            Errors = @()
            StartTime = Get-Date
        }
    } 
    
    Process {
        try {
            # Create output directory if it doesn't exist
            if (-not (Test-Path $OutputPath)) {
                Write-Verbose "Creating output directory: $OutputPath"
                New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
            }
            
            # Get categories to export
            if ($CategoryID) {
                Write-Verbose "Exporting specific category: $CategoryID"
                $categories = @(Get-FsArticleCategory -ID $CategoryID)
            } else {
                Write-Verbose "Exporting all categories"
                $categories = Get-FsArticleCategory
            }
            
            foreach ($category in $categories) {
                Write-Host "Exporting category: $($category.name)" -ForegroundColor Green
                
                # Create category folder with safe name
                $categoryFolderName = ConvertTo-SafeFolderName -Name $category.name
                $categoryPath = Join-Path $OutputPath $categoryFolderName
                
                if (-not (Test-Path $categoryPath)) {
                    New-Item -ItemType Directory -Path $categoryPath -Force | Out-Null
                }
                
                # Export category metadata
                $categoryMetadata = $category | Select-Object * -ExcludeProperty CategoryName, CategoryID
                $categoryMetadataPath = Join-Path $categoryPath ".category.json"
                $categoryMetadata | ConvertTo-Json -Depth 10 | Out-File -FilePath $categoryMetadataPath -Encoding UTF8
                Write-Verbose "Exported category metadata: $categoryMetadataPath"
                
                $exportSummary.CategoriesExported++
                
                # Get folders in this category
                try {
                    $folders = Get-FsArticleFolder -CategoryID $category.id
                    
                    foreach ($folder in $folders) {
                        Write-Host "  Exporting folder: $($folder.name)" -ForegroundColor Yellow
                        
                        # Create folder directory with safe name
                        $folderName = ConvertTo-SafeFolderName -Name $folder.name
                        $folderPath = Join-Path $categoryPath $folderName
                        
                        if (-not (Test-Path $folderPath)) {
                            New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
                        }
                        
                        # Export folder metadata
                        $folderMetadata = $folder | Select-Object * -ExcludeProperty CategoryName, CategoryID, FolderName, FolderID
                        $folderMetadataPath = Join-Path $folderPath ".folder.json"
                        $folderMetadata | ConvertTo-Json -Depth 10 | Out-File -FilePath $folderMetadataPath -Encoding UTF8
                        Write-Verbose "Exported folder metadata: $folderMetadataPath"
                        
                        $exportSummary.FoldersExported++
                        
                        # Get articles in this folder
                        try {
                            $articles = Get-FsArticle -FolderID $folder.id
                            
                            foreach ($article in $articles) {
                                Write-Host "    Exporting article: $($article.title)" -ForegroundColor Cyan
                                
                                # Create safe filename from article title
                                $articleFileName = ConvertTo-SafeFileName -Name $article.title
                                
                                # Export article HTML content
                                $htmlPath = Join-Path $folderPath "$articleFileName.html"
                                if ($Force -or -not (Test-Path $htmlPath) -or $PSCmdlet.ShouldProcess($htmlPath, "Export article HTML")) {
                                    $article.description | Out-File -FilePath $htmlPath -Encoding UTF8
                                    Write-Verbose "Exported article HTML: $htmlPath"
                                }
                                
                                # Export article metadata (excluding content)
                                $articleMetadata = $article | Select-Object * -ExcludeProperty description, CategoryName, CategoryID, FolderName, FolderID
                                $jsonPath = Join-Path $folderPath "$articleFileName.json"
                                if ($Force -or -not (Test-Path $jsonPath) -or $PSCmdlet.ShouldProcess($jsonPath, "Export article metadata")) {
                                    $articleMetadata | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonPath -Encoding UTF8
                                    Write-Verbose "Exported article metadata: $jsonPath"
                                }
                                
                                $exportSummary.ArticlesExported++
                            }
                        }
                        catch {
                            $errorMsg = "Failed to export articles from folder '$($folder.name)': $_"
                            Write-Warning $errorMsg
                            $exportSummary.Errors += $errorMsg
                        }
                    }
                }
                catch {
                    $errorMsg = "Failed to export folders from category '$($category.name)': $_"
                    Write-Warning $errorMsg
                    $exportSummary.Errors += $errorMsg
                }
            }
            
            # Update final summary
            $exportSummary.EndTime = Get-Date
            $exportSummary.Duration = $exportSummary.EndTime - $exportSummary.StartTime
            
            Write-Host "`nExport completed!" -ForegroundColor Green
            Write-Host "Categories: $($exportSummary.CategoriesExported)" -ForegroundColor White
            Write-Host "Folders: $($exportSummary.FoldersExported)" -ForegroundColor White  
            Write-Host "Articles: $($exportSummary.ArticlesExported)" -ForegroundColor White
            Write-Host "Duration: $($exportSummary.Duration.ToString('mm\:ss'))" -ForegroundColor White
            
            if ($exportSummary.Errors.Count -gt 0) {
                Write-Host "Errors: $($exportSummary.Errors.Count)" -ForegroundColor Red
                $exportSummary.Errors | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
            }
            
            return [PSCustomObject]$exportSummary
        }
        catch {
            Write-Error "Export failed: $_"
            throw
        }
    } 
    
    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}

Function ConvertTo-SafeFolderName {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )
    
    # Remove invalid characters and replace with underscores
    $safeName = $Name -replace '[<>:"/\\|?*]', '_'
    # Remove multiple consecutive underscores
    $safeName = $safeName -replace '_{2,}', '_'
    # Remove leading/trailing underscores
    $safeName = $safeName.Trim('_')
    # Limit length
    if ($safeName.Length -gt 100) {
        $safeName = $safeName.Substring(0, 100).TrimEnd('_')
    }
    
    return $safeName
}

Function ConvertTo-SafeFileName {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )
    
    # Remove invalid characters and replace with underscores
    $safeName = $Name -replace '[<>:"/\\|?*]', '_'
    # Remove multiple consecutive underscores  
    $safeName = $safeName -replace '_{2,}', '_'
    # Remove leading/trailing underscores
    $safeName = $safeName.Trim('_')
    # Limit length (accounting for .html/.json extensions)
    if ($safeName.Length -gt 200) {
        $safeName = $safeName.Substring(0, 200).TrimEnd('_')
    }
    
    return $safeName
}

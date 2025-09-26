**SPSFreshService**

*PowerShell module for FreshService using 'https://api.freshservice.com/'*

### Local Development
For local testing and development:
```powershell
# Build locally for testing
.\build.ps1 -Local

# Build with version increment for testing
.\build.ps1 -Local -IncrementVersion

# Build and run tests
.\build.ps1 -Local -Test
```

### CI/CD Pipeline
- **Automatic builds** on push to main branch
- **Version management** using `<ModuleVersion>` placeholder that gets replaced during build
- **Function export** automatically populated from Public folder during build
- **Testing integration** with Pester
- **NuGet packaging** and deployment to Azure DevOps Artifacts

## Recent Updates

### Solution Articles Management (Work in Progress)
The module now includes comprehensive functions for managing FreshService Solution Articles, Categories, and Folders. These functions provide full CRUD (Create, Read, Update, Delete) operations and knowledge base synchronization capabilities.

**⚠️ Note: These Solution Article functions are currently in development and have not been fully tested. Use with caution in production environments.**

#### New Solution Article Functions:
- **Article Management**: `Get-FsArticle`, `New-FsArticle`, `Update-FsArticle`, `Remove-FsArticle`
- **Category Management**: `Get-FsArticleCategory`, `New-FsArticleCategory`, `Update-FsArticleCategory`, `Remove-FsArticleCategory`
- **Folder Management**: `Get-FsArticleFolder`, `New-FsArticleFolder`, `Update-FsArticleFolder`, `Remove-FsArticleFolder`
- **Knowledge Base Sync**: `Export-FsKnowledgeBase`, `Import-FsKnowledgeBase`, `Sync-FsKnowledgeBase`

#### Key Features:
- **Hierarchical Access**: Use `-All` parameter to retrieve complete category/folder/article hierarchies
- **GitHub Integration**: Export knowledge base to git-friendly folder structure with HTML content and JSON metadata
- **Version Control**: Sync FreshService articles with local repositories for change tracking
- **Bulk Operations**: Process entire knowledge bases or specific categories/folders

#### Current Status:
- ✅ Core article CRUD operations implemented
- ✅ Category and folder management functions created  
- ✅ Knowledge base export/import/sync functions developed
- 🧪 **Testing in progress** - Please report any issues encountered

#### Known Issues:
- Module import may require reload after function renaming
- Configuration domain export logic recently fixed
- Some edge cases in hierarchical traversal may need refinement

## Installation Instructions

Install the module from your organization's package feed:

```powershell
# Install from Azure DevOps Artifacts (if you have access)
Install-Module -Name SPSFreshService -Repository YourOrgFeed

# Or install from a local package
Install-Module -Name SPSFreshService -Repository PSGallery
```

Configure the module with your FreshService domain and API key:

```powershell
# Set up your FreshService configuration
Set-SPSFreshServiceConfiguration -Domain "yourcompany" -APIKey "your-api-key"

# Verify the configuration
Get-SPSFreshServiceWindowsConfiguration
```

**Examples:**

*Get all Solution Articles with hierarchical structure*
```powershell
Get-FsArticle -All
```

*Export entire knowledge base to local folder*
```powershell
Export-FsKnowledgeBase -OutputPath "C:\MyRepo\Articles" -Verbose
```

*Get all categories and their folders*
```powershell
Get-FsArticleCategory -All
```

*Create a new article in a specific folder*
```powershell
New-FsArticle -Title "Troubleshooting Guide" -FolderID 123 -Description "<h1>Step 1</h1><p>First step...</p>"
```

### Legacy Examples:

*This will list all tickets*

Get-FsTicket

-------------------------------

*This will list a ticket with ID Number 1234*

Get-FsTicket -ID 1234

-------------------------------

*This will list all tickets with a priority of 2 (Medium)*

Get-FsTicket -Priority Medium

-------------------------------

*More examples shown under the '.EXAMPLE' at the start of each function*
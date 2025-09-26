Function Update-FsArticle {
<#
.SYNOPSIS
    Updates an existing Solution Article in FreshService
.DESCRIPTION
    The Update-FsArticle function updates an existing solution article in your FreshService domain
.EXAMPLE
    Update-FsArticle -ID 1 -Title "Updated Title" -Description "<p>Updated content...</p>"
    Updates an existing article with new title and description
.PARAMETER ID
    The ID of the article to update (required)
.PARAMETER Title
    The title of the article
.PARAMETER Description  
    The HTML description/content of the article
.PARAMETER FolderID
    The folder ID where the article will be moved
.PARAMETER CategoryID
    The category ID for the article
.PARAMETER Status
    The status of the article (Draft, Published)
.PARAMETER ArticleType
    The type of article (Permanent, Workaround)
.PARAMETER AgentID
    The ID of the agent updating the article
.PARAMETER Keywords
    Array of keywords for the article
.PARAMETER ReviewDate
    Review date for the article
.PARAMETER WorkspaceID
    The workspace ID
.INPUTS
    String, Int
.OUTPUTS
    PSCustomObject
.NOTES
    Requires FreshService API connection
.LINK
    https://api.freshservice.com/v2/#update_solution_article
#>
    [CmdletBinding()] 
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            Position=0)]
            [String]$ID,
        
        [Parameter(Mandatory=$false)]
            [String]$Title,
        
        [Parameter(Mandatory=$false)]
            [String]$Description,
        
        [Parameter(Mandatory=$false)]
            [Int]$FolderID,
        
        [Parameter(Mandatory=$false)]
            [Int]$CategoryID,
        
        [Parameter(Mandatory=$false)]
            [ValidateSet("Draft","Published")]
            [String]$Status,
        
        [Parameter(Mandatory=$false)]
            [ValidateSet("Permanent","Workaround")]
            [String]$ArticleType,
        
        [Parameter(Mandatory=$false)]
            [Int]$AgentID,
        
        [Parameter(Mandatory=$false)]
            [String[]]$Keywords,
        
        [Parameter(Mandatory=$false)]
            [String[]]$Tags,
        
        [Parameter(Mandatory=$false)]
            [DateTime]$ReviewDate,
        
        [Parameter(Mandatory=$false)]
            [Int]$WorkspaceID
    )

    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI

        $StatusInt = $null
        switch ($Status) {
            Draft     {$StatusInt = 1}
            Published {$StatusInt = 2}
        }

        $ArticleTypeInt = $null
        switch ($ArticleType) {
            Permanent  {$ArticleTypeInt = 1}
            Workaround {$ArticleTypeInt = 2}
        }
    }
    
    Process {
        $Attributes = @{}
        
        if ($Title) {
            $Attributes.Add('title', $($Title))
        }
        if ($Description) {
            $Attributes.Add('description', $($Description))
        }
        if ($FolderID) {
            $Attributes.Add('folder_id', $($FolderID))
        }
        if ($CategoryID) {
            $Attributes.Add('category_id', $($CategoryID))
        }
        if ($StatusInt) {
            $Attributes.Add('status', $($StatusInt))
        }
        if ($ArticleTypeInt) {
            $Attributes.Add('article_type', $($ArticleTypeInt))
        }
        if ($AgentID) {
            $Attributes.Add('agent_id', $($AgentID))
        }
        if ($Keywords) {
            $Attributes.Add('keywords', $($Keywords))
        }
        if ($Tags) {
            $Attributes.Add('tags', $($Tags))
        }
        if ($ReviewDate) {
            $Attributes.Add('review_date', $($ReviewDate.ToString('yyyy-MM-ddTHH:mm:ssZ')))
        }
        if ($WorkspaceID) {
            $Attributes.Add('workspace_id', $($WorkspaceID))
        }

        $Body = $Attributes | ConvertTo-Json
        Write-Verbose -Message "Request body: $Body"

        Get-FreshServiceAPIResult -APIEndpoint "$($Script:APIURL)/solutions/articles/$($ID)" -Body $Body -Method 'PUT'
    }
    
    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}

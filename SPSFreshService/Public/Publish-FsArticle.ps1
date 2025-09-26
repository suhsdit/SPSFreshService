Function Publish-FsArticle {
<#
.SYNOPSIS
    Publishes a Solution Article in FreshService
.DESCRIPTION
    The Publish-FsArticle function publishes a draft solution article, changing its status to published
.EXAMPLE
    Publish-FsArticle -ID 1
    Publishes the article with ID 1
.EXAMPLE
    Get-FsArticle -FolderID 2 | Where-Object {$_.status -eq 1} | Publish-FsArticle
    Publishes all draft articles in folder 2
.PARAMETER ID
    The ID of the article to publish (required)
.INPUTS
    String
.OUTPUTS
    PSCustomObject
.NOTES
    Requires FreshService API connection
    Article must be in draft status to be published
    May require approval workflow completion first
.LINK
    https://api.freshservice.com/v2/#publish_solution_article
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')] 
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
            [String]$ID
    )

    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
    }
    
    Process {
        if ($PSCmdlet.ShouldProcess("Article ID: $ID", "Publish Solution Article")) {
            $Attributes = @{
                'status' = 2  # Published status
            }

            $Body = $Attributes | ConvertTo-Json
            Write-Verbose -Message "Publishing article ID $ID"
            Write-Verbose -Message "Request body: $Body"

            Get-FreshServiceAPIResult -APIEndpoint "$($Script:APIURL)/solutions/articles/$($ID)" -Body $Body -Method 'PUT'
        }
    }
    
    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}

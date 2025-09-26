Function Send-FsArticleForApproval {
<#
.SYNOPSIS
    Sends a Solution Article for approval in FreshService
.DESCRIPTION
    The Send-FsArticleForApproval function sends a solution article through the approval workflow process
.EXAMPLE
    Send-FsArticleForApproval -ID 1
    Sends article with ID 1 for approval
.EXAMPLE
    Get-FsArticle -FolderID 2 | Where-Object {$_.status -eq 1 -and $_.approval_status -eq $null} | Send-FsArticleForApproval
    Sends all draft articles without approval status for approval
.PARAMETER ID
    The ID of the article to send for approval (required)
.INPUTS
    String
.OUTPUTS
    PSCustomObject
.NOTES
    Requires FreshService API connection
    Article must be in draft status and approval workflow must be configured
    After approval, use Publish-FsArticle to publish the article
.LINK
    https://api.freshservice.com/v2/#send_article_to_approval
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')] 
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
        if ($PSCmdlet.ShouldProcess("Article ID: $ID", "Send Solution Article for Approval")) {
            Write-Verbose -Message "Sending article ID $ID for approval"

            Get-FreshServiceAPIResult -APIEndpoint "$($Script:APIURL)/solutions/articles/$($ID)/send_for_approval" -Body '' -Method 'PUT'
        }
    }
    
    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}

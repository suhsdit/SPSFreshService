Function Remove-FsArticle {
<#
.SYNOPSIS
    Deletes a Solution Article from FreshService
.DESCRIPTION
    The Remove-FsArticle function deletes a solution article from your FreshService domain
.EXAMPLE
    Remove-FsArticle -ID 1
    Deletes the article with ID 1
.EXAMPLE
    Get-FsArticle -FolderID 2 | Where-Object {$_.title -like "*old*"} | Remove-FsArticle
    Removes all articles in folder 2 that have "old" in the title
.PARAMETER ID
    The ID of the article to delete (required)
.INPUTS
    String
.OUTPUTS
    None (HTTP 204 No Content on success)
.NOTES
    Requires FreshService API connection
    This action cannot be undone
.LINK
    https://api.freshservice.com/v2/#delete_solution_article
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')] 
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
        if ($PSCmdlet.ShouldProcess("Article ID: $ID", "Delete Solution Article")) {
            try {
                Write-Verbose -Message "Deleting article with ID: $ID"
                $Result = Invoke-WebRequest -Uri "$($Script:APIURL)/solutions/articles/$($ID)" -Headers $headers -Method DELETE
                
                if ($Result.StatusCode -eq 204) {
                    Write-Verbose -Message "Article ID $ID deleted successfully"
                }
                else {
                    Write-Warning -Message "Unexpected status code: $($Result.StatusCode)"
                }
            }
            catch {
                Write-Error -Message "Failed to delete article ID $ID. Error: $_"
            }
        }
    }
    
    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}

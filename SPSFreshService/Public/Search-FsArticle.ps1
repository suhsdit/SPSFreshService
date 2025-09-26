Function Search-FsArticle {
<#
.SYNOPSIS
    Searches for Solution Articles in FreshService
.DESCRIPTION
    The Search-FsArticle function searches for solution articles across your FreshService domain using keywords
.EXAMPLE
    Search-FsArticle -SearchTerm "password reset"
    Searches for articles containing "password reset"
.EXAMPLE
    Search-FsArticle -SearchTerm "VPN" -UserEmail "user@domain.com"
    Searches for VPN articles accessible by the specified user
.PARAMETER SearchTerm
    The keywords to search for in solution articles (required)
.PARAMETER UserEmail
    Email of the user to search as (uses their permissions for article access)
.PARAMETER WorkspaceID
    The workspace ID to search in
.INPUTS
    String
.OUTPUTS
    PSCustomObject[]
.NOTES
    Requires FreshService API connection
    Only returns published articles that the user has access to
.LINK
    https://api.freshservice.com/v2/#search_solution_articles
#>
    [CmdletBinding()] 
    Param(
        [Parameter(Mandatory=$true,
            Position=0)]
            [String]$SearchTerm,
        
        [Parameter(Mandatory=$false)]
            [String]$UserEmail,
        
        [Parameter(Mandatory=$false)]
            [Int]$WorkspaceID
    )
    
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
    } 
    
    Process {
        $APIEndpoint = "$($Script:APIURL)/solutions/articles/search"
        $QueryParams = @()
        
        # Add search term (required)
        $QueryParams += "search_term=$([uri]::EscapeDataString($SearchTerm))"
        
        # Add optional parameters
        if ($UserEmail) {
            $QueryParams += "user_email=$([uri]::EscapeDataString($UserEmail))"
        }
        
        if ($WorkspaceID) {
            $QueryParams += "workspace_id=$WorkspaceID"
        }
        
        # Build final endpoint
        if ($QueryParams.Count -gt 0) {
            $APIEndpoint += "?" + ($QueryParams -join "&")
        }
        
        Write-Verbose "API Endpoint: $($APIEndpoint)"
        Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'articles' -Paginate $true -Method 'GET'
    } 
    
    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}

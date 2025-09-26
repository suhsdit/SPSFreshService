Function Remove-FsArticleCategory {
<#
.SYNOPSIS
    Removes a Solution Article Category from FreshService
.DESCRIPTION
    The Remove-FsArticleCategory function deletes a solution article category from your FreshService domain.
    This action cannot be undone and will also delete all folders and articles within the category.
.EXAMPLE
    Remove-FsArticleCategory -ID 123
    Removes the category with ID 123
.EXAMPLE
    Get-FsArticleCategory -ID 123 | Remove-FsArticleCategory -Confirm:$false
    Removes category 123 without confirmation prompt
.PARAMETER ID
    The ID of the category to remove (required)
.PARAMETER Force
    Bypasses the confirmation prompt
.INPUTS
    [Int64] - ID can be passed via pipeline
    [PSCustomObject] - Category objects can be passed via pipeline
.OUTPUTS
    [PSCustomObject] - Returns confirmation of deletion from FreshService
.NOTES
    Requires FreshService API authentication with appropriate permissions
    WARNING: This action cannot be undone and will delete all content within the category
.LINK
    https://api.freshservice.com/v2/#delete_solution_category
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
            [Int64]$ID,
            
        [Parameter(Mandatory=$false)]
            [switch]$Force
    )
    
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName)..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
    } 
    
    Process {
        $APIEndpoint = "$($Script:APIURL)/solutions/categories/$($ID)"
        Write-Verbose "API Endpoint: $($APIEndpoint)"
        
        if ($Force -or $PSCmdlet.ShouldProcess("Category ID $ID", "Delete Solution Category")) {
            # Make the API call
            $APIParams = @{
                APIEndpoint = $APIEndpoint
                PrimaryObject = 'category'
                Paginate = $false
                Method = 'DELETE'
            }
            
            Get-FreshServiceAPIResult @APIParams
        }
        else {
            Write-Warning "Category deletion cancelled by user."
        }
    } 
    
    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}

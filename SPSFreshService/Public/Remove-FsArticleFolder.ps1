Function Remove-FsArticleFolder {
<#
.SYNOPSIS
    Removes a Solution Article Folder from FreshService
.DESCRIPTION
    The Remove-FsArticleFolder function deletes a solution article folder from your FreshService domain.
    This action cannot be undone and will also delete all sub-folders and articles within the folder.
.EXAMPLE
    Remove-FsArticleFolder -ID 456
    Removes the folder with ID 456
.EXAMPLE
    Get-FsArticleFolder -ID 456 | Remove-FsArticleFolder -Confirm:$false
    Removes folder 456 without confirmation prompt
.PARAMETER ID
    The ID of the folder to remove (required)
.PARAMETER Force
    Bypasses the confirmation prompt
.INPUTS
    [Int64] - ID can be passed via pipeline
    [PSCustomObject] - Folder objects can be passed via pipeline
.OUTPUTS
    [PSCustomObject] - Returns confirmation of deletion from FreshService
.NOTES
    Requires FreshService API authentication with appropriate permissions
    WARNING: This action cannot be undone and will delete all content within the folder
.LINK
    https://api.freshservice.com/v2/#delete_solution_folder
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
        $APIEndpoint = "$($Script:APIURL)/solutions/folders/$($ID)"
        Write-Verbose "API Endpoint: $($APIEndpoint)"
        
        if ($Force -or $PSCmdlet.ShouldProcess("Folder ID $ID", "Delete Solution Folder")) {
            # Make the API call
            $APIParams = @{
                APIEndpoint = $APIEndpoint
                PrimaryObject = 'folder'
                Paginate = $false
                Method = 'DELETE'
            }
            
            Get-FreshServiceAPIResult @APIParams
        }
        else {
            Write-Warning "Folder deletion cancelled by user."
        }
    } 
    
    End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}

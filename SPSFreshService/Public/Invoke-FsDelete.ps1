Function Invoke-FsDelete {
<#
.SYNOPSIS
    Invokes a general API request for data to be deleted from your Freshservice domain
.DESCRIPTION
    The Invoke-FsDelete function deleted anything from your FreshService domain
    *REQUIRED PARAMS* - FsCategory, ID
.EXAMPLE
    Invoke-FsDelete -FsCategory 'vendors' -ID '12345678'
.PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
    [CmdletBinding()] #Enable all the default paramters, including
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            Position=0)]
            [String]$FsCategory,
        
        [Parameter(Mandatory=$false,
            Position=1)]
            [String]$ID
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
        # $ResultsPerPage = 100
        # $page = 1
    }
    Process{

        Invoke-WebRequest -Uri "$($APIURL)/$($FsCategory)/$($ID)" -Headers $headers -Method Delete
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
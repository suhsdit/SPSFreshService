Function Get-FsAnalyticsDataExport {
<#
.SYNOPSIS
    Gets data from freshservice export 
.DESCRIPTION
    The Get-FsAnalyticsDataExport function pulls any data through the data export feature of freshservice
    *REQUIRED PARAMS* - FsURL
.EXAMPLE
    Get-FsAnalyticsDataExport -FsURL 'https://contoso.freshservice.com. . . . ' 
.PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
    [CmdletBinding()] #Enable all the default paramters, including
    Param(
        [Parameter(Mandatory=$true,
            Position=0)]
            [String]$FsURL
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
    }
    Process{
        Invoke-WebRequest -Uri $FsURL -Headers $headers -Method Get
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
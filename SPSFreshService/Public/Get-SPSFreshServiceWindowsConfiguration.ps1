Function Get-SPSFreshServiceWindowsConfiguration {
<#
.SYNOPSIS
    Get the current configuration for the SPSFreshService Module
.DESCRIPTION
    Get the current configuration for the SPSFreshService Module
.EXAMPLE
    Get-SPSFreshServiceConfiguration
    Get the current config
.PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
    [CmdletBinding()] #Enable all the default paramters, including
    Param(
        [Parameter(Mandatory=$false,
            ValueFromPipeline=$false,
            ValueFromPipelineByPropertyName=$false,
            # HelpMessage='HelpMessage',
            Position=0)]
            [String]$Name
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        
    }
    Process{
        # If no users are specified, get all students
        try{
            Write-Output $Script:SPSFreshServiceConfigName
        }
        catch{
            Write-Error -Message "$_ went wrong."
        }
        
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
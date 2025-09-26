Function Set-SPSFreshServiceConfiguration {
<#
.SYNOPSIS
    Set the configuration to use for the SPSFreshService Module
.DESCRIPTION
    Set the configuration to use for the SPSFreshService Module
.EXAMPLE
    Set-SPSFreshServiceConfiguration -Name contoso
    Set the configuration to Name
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
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
            [String]$Name,
        
        [Parameter(Mandatory=$true)]
            [String]$Domain,
        
        [Parameter(Mandatory=$true)]
            [String]$APIKey
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        
    }
    Process{
        try{
            Write-Verbose -Message "Changing Config from $($Script:SPSFreshServiceConfigName) to $($Name)"
            $Script:SPSFreshServiceConfigName = $Name

            $Script:APIURL = "https://$($Domain).freshservice.com/api/v2"

            $Script:APIKey = $APIKey
        }
        catch{
            Write-Error -Message "$_ went wrong."
        }
        
        
        
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
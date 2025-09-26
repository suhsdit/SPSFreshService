Function Set-SPSFreshServiceWindowsConfiguration {
<#
.SYNOPSIS
    Set the configuration to use for the SPSFreshService Module
.DESCRIPTION
    Set the configuration to use for the SPSFreshService Module
.EXAMPLE
    Set-SPSFreshServiceWindowsConfiguration -Name contoso
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
            [String]$Name
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        
    }
    Process{
        try{
            Write-Verbose -Message "Changing Config from $($Script:SPSFreshServiceConfigName) to $($Name)"
            $Script:SPSFreshServiceConfigName = $Name

            $Script:SPSFreshServiceConfigDir = "$Env:USERPROFILE\AppData\Local\powershell\SPSFreshService\$Name"
            Write-Verbose -Message "Config dir: $SPSFreshServiceConfigDir"

            $Script:Config = Get-Content -Raw -Path "$Script:SPSFreshServiceConfigDir\config.json" | ConvertFrom-Json
            Write-Verbose -Message "Importing config.json"

            $Script:APIURL = "https://$($Config.Domain).freshservice.com/api/v2"

            $Script:APIKey = Import-Clixml -Path "$Script:SPSFreshServiceConfigDir\apikey.xml"
            $Script:APIKey = $APIKey.GetNetworkCredential().Password
            Write-Verbose -Message "Importing apikey.xml"
        }
        catch{
            Write-Error -Message "$_ went wrong."
        }
        
        
        
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
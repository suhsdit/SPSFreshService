Function New-SPSFreshServiceWindowsConfiguration {
<#
.SYNOPSIS
    Setup new configuration to use for the SPSFreshService Module
.DESCRIPTION
    Setup new configuration to use for the SPSFreshService Module
.EXAMPLE
    New-SPSFreshServiceConfiguration
    Start the process of setting config. Follow prompts.
.PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
    [CmdletBinding()] #Enable all the default paramters, including
    Param(
        [Parameter(Mandatory=$false,
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
        # If no users are specified, get all students
        try{
            if (!$Name) {
                $Name = Read-Host "Config Name"
            }

            if(!(Test-Path -path "$SPSFreshServiceConfigRoot\$Name")) {
                New-Item -ItemType Directory -Name $Name -Path $Script:SPSFreshServiceConfigRoot
                $Script:SPSFreshServiceConfigDir = "$Script:SPSFreshServiceConfigRoot\$Name"

                Write-Verbose -Message "Setting new Config file"

                $Domain = Read-Host 'Your FreshService Domain'
                Get-Credential -UserName ' ' -Message 'Enter your FrehService API Key' | Export-Clixml "$SPSFreshServiceConfigDir\apikey.xml"

                @{Config=$Name;Domain=$Domain} | ConvertTo-Json | Out-File "$SPSFreshServiceConfigDir\config.json"

                # Set the new files as active
                Set-SPSFreshServiceWindowsConfiguration $Name
            }
            else {
                Write-Warning -Message "Config already exists."
                break
            }
        }
        catch{
            Write-Error -Message "$_ went wrong."
        }
        
        
        
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
# Template for module courtesy of RamblingCookieMonster
#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($Public + $Private))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Here I might...
# Read in or create an initial config file and variable


# Export Public functions ($Public.BaseName) for WIP modules

# FS Config info, set script variables
New-Variable -Name SPSFreshServiceConfigName -Scope Script -Force
New-Variable -Name SPSFreshServiceConfigRoot -Scope Script -Force
$SPSFreshServiceConfigRoot = "$Env:USERPROFILE\AppData\Local\powershell\SPSFreshService"
New-Variable -Name SPSFreshServiceConfigDir -Scope Script -Force
New-Variable -Name Config -Scope Script -Force
New-Variable -Name APIKey -Scope Script -Force
New-Variable -Name APIURL -Scope Script -Force

Export-ModuleMember -Function $Public.Basename
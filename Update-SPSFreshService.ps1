# This function is used to help update the module while developing and testing...
Function Update-SPSFreshService {
    [CmdletBinding()] #Enable all the default paramters, including
    Param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$false,
            Position=0)]
            [string]$config
    )
    Write-Host "[X] Removing SPSFreshService Module..." -ForegroundColor Green
    Get-Module SPSFreshService | Remove-Module
    Write-Host "[X] Importing SPSFreshService Module from .\SPSFreshService..." -ForegroundColor Green
    Import-Module .\SPSFreshService
    Write-Host "[X] Setting SPSFreshService config to $config..." -ForegroundColor Green
    Set-SPSFreshServiceWindowsConfiguration $config
    Write-Host "[X] Updated SPSFreshService ready to use. Using Config:" -ForegroundColor Green
    Get-SPSFreshServiceConfiguration
}
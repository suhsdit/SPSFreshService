#region: Mock a config and load it for other functions to use
Mock 'Set-SPSFreshServiceWindowsConfiguration' -ModuleName SPSFreshService -MockWith {
    Write-Verbose "Getting mocked SPSFreshService config"
    $script:SPSFreshService = [PSCustomObject][Ordered]@{
        ConfigName = 'Pester'
        APIKey = ([System.IO.Path]::Combine($PSScriptRoot,"fake_api_key.xml"))
        APIURL = 'https://prefix.domain.com/api/v3/'
    }
}
Set-SPSFreshServiceWindowsConfiguration
#endregion


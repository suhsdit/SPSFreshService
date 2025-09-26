Function Connect-FreshServiceAPI {
    try {
        Write-Verbose "Using Config: $Script:Config"
        Write-Verbose "APIURL: $Script:APIURL"
    
        #Headers for FreshService API
        Write-Verbose "APIKey: [REDACTED]"
        $encodedapikey = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($Script:APIKey):X"))
        Write-Verbose "EncodedAPIKey: [REDACTED]"
        $script:headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $script:headers.Add('Authorization', "Basic $encodedapikey")
        $script:headers.Add('Content-Type', 'application/json')
    }
    catch {
        Write-Error -Message "$_ went wrong."
    }
}
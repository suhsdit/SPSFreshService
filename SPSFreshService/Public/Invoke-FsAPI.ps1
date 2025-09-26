Function Invoke-FsAPI {
<#
.SYNOPSIS
    Invokes a general API request for data to be queried from your Freshservice domain
.DESCRIPTION
    The Invoke-FsAPI function can access any data from your FreshService domain
    *REQUIRED PARAMS* Query, Method, Paginate (Primary Object is highly recommended)
.EXAMPLE
    Invoke-FsAPI -PrimaryObject 'agents' -Query 'agents?query="first_name:JR"' -Method 'Get' -Paginate '$false'
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
            [String]$Query,

        [Parameter(Mandatory=$false,
            Position=1)]
            [String]$PrimaryObject,
            
        [Parameter(Mandatory=$false,
            Position=2)]
            [ValidateSet("Post","Get","Delete","Put")]
            [String]$Method="Get",

        [Parameter(Mandatory=$false,
            Position=3)]
            [Boolean]$Paginate=$true,
        
        [Parameter(Mandatory=$false)]
            [int32]$Pages = 10000
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
        $APIEndpoint = "$($APIURL)/$Query"
        $PrimaryObject = $Query.Split('/')[0]
    }
    Process{
        Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject $PrimaryObject -Paginate $Paginate -Pages $Pages -Method $Method
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
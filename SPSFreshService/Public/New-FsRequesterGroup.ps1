Function New-FsRequesterGroup {
<#
.SYNOPSIS
    Creates a requester group within FreshService
.DESCRIPTION
    The New-FsRequesterGroups function inputs a new requester group in the FreshService domain
    *REQUIRED PARAMS* - Name
.EXAMPLE
    New-FsRequester group -Name 'DDSD' . . .
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
            [String]$Name,
        
        [Parameter(Mandatory=$false,
            Position=1)]
            [String]$Description,
        
        [Parameter(Mandatory=$false,
            Position=2)]
            [Int]$ID,
        
        [Parameter(Mandatory=$false,
            Position=3)]
            [String]$Type
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
    }
    Process{

        $Attributes = @{}
        if ($Name){
            $Attributes.Add('name', $($Name))
        }
        if ($Description){
            $Attributes.Add('description', $($Description))
        }
        if ($ID){
            $Attributes.Add('id', $($ID))
        }
        if ($Type){
            $Attributes.Add('type', $($Type))
        }

        $Body = $Attributes | ConvertTo-Json

        Get-FreshServiceAPIResult -APIEndpoint "$($APIURL)/requester_groups" -Body $Body -Method 'POST'
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
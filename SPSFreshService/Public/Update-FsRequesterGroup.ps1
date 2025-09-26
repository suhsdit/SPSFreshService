Function Update-FsRequesterGroup {
<#
.SYNOPSIS
    Updates a requester group within FreshService
.DESCRIPTION
    The Update-FsRequesterGroup function updates a requester group in the FreshService domain
    *REQUIRED PARAMS* Name, UpdateID
.EXAMPLE
    Update-FsRequesterGroup -Name 'John' -Description 'test description' . . .
.PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
    [CmdletBinding()] #Enable all the default paramters, including
    Param(
        [Parameter(Mandatory=$true,
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
            [String]$Type,

        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            Position=4)]
            [String]$UpdateID
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

        Get-FreshServiceAPIResult -APIEndpoint "$($APIURL)/requester_groups/$($UpdateID)" -Body $Body -Method 'PUT'
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
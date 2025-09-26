Function Update-FsDepartment {
<#
.SYNOPSIS
    Creates a department within FreshService
.DESCRIPTION
    The New-FsDepartment function inputs a new department into the FreshService domain
    *REQUIRED PARAMS* - Name, UpdateID
.EXAMPLE
    New-FsDepartment -Name 'EESD' . . . 
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
            [int]$ID,
        
        [Parameter(Mandatory=$false,
            Position=2)]
            [String]$Description,
        
        [Parameter(Mandatory=$false,
            Position=3)]
            [Int]$HeadUserID,
        
        [Parameter(Mandatory=$false,
            Position=4)]
            [Int]$PrimeUserID,
        
        [Parameter(Mandatory=$false,
            Position=6)]
            [String[]]$Domains,
        
        [Parameter(Mandatory=$false,
            Position=7)]
            [Hashtable]$CustomFields,
        
        [Parameter(Mandatory=$false,
            Position=8)]
            [DateTime]$CreatedAt,
        
        [Parameter(Mandatory=$false,
            Position=10)]
            [DateTime]$UpdatedAt,

        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            Position=11)]
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
        if ($ID){
            $Attributes.Add('id', $($ID))
        }
        if ($Description){
            $Attributes.Add('description', $($Description))
        }
        if ($HeadUserID){
            $Attributes.Add('head_user_id', $($HeadUserID))
        }
        if ($PrimeUserID){
            $Attributes.Add('prime_user_id', $($PrimeUserID))
        }
        if ($Domains){
            $Attributes.Add('domains', $($Domains))
        }
        if ($CustomFields){
            $Attributes.Add('custom_fields', $($CustomFields))
        }
        if ($CreatedAt){
            $Attributes.Add('created_at', $($CreatedAt))
        }
        if ($UpdatedAt){
            $Attributes.Add('updated_at', $($UpdatedAt))
        }
        $Body = $Attributes | ConvertTo-Json

        Get-FreshServiceAPIResult -APIEndpoint "$($APIURL)/departments/$($UpdateID)" -Body $Body -Method 'PUT'
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
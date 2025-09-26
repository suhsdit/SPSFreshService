Function Update-FsVendor {
<#
.SYNOPSIS
    Updates a vendor within FreshService
.DESCRIPTION
    The Update-FsVendor function updates an existing vendor in the FreshService domain
    *MANDATORY FIELDS* - Name, UpdateID
.EXAMPLE
    Update-FsVendor -Name 'John' -Description 'test description' . . .
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
            [Int]$ContactID,
        
        [Parameter(Mandatory=$false,
            Position=3)]
            [String]$Address,
        
        [Parameter(Mandatory=$false,
            Position=4)]
            [String]$City,
        
        [Parameter(Mandatory=$false,
            Position=5)]
            [String]$State,
        
        [Parameter(Mandatory=$false,
            Position=6)]
            [String]$Country,
        
        [Parameter(Mandatory=$false,
            Position=7)]
            [String]$Zipcode,
        
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            Position=8)]
            [String]$UpdateID
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
    }
    Process{

        $Attributes = @{}
        $Address = @{}
        if ($Name){
            $Attributes.Add('name', $($Name))
        }
        if ($Description){
            $Attributes.Add('description', $($Description))
        }
        if ($ContactID){
            $Attributes.Add('primary_contact_id', $($ContactID))
        }
        if ($Line1){
            $Address.Add('line1', $($Line1))
        }
        if ($City){
            $Address.Add('city', $($City))
        }
        if ($State){
            $Address.Add('state', $($State))
        }
        if ($Country){
            $Address.Add('country', $($Country))
        }
        if ($Zipcode){
            $Address.Add('zipcode', $($Zipcode))
        }
        if ($Line1 -or $City -or $State -or $Country -or $Zipcode){
            $Attributes.Add('address', $($Address))
        }

        $Body = $Attributes | ConvertTo-Json

        Get-FreshServiceAPIResult -APIEndpoint "$($APIURL)/vendors/$($UpdateID)" -Body $Body -Method 'PUT'
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
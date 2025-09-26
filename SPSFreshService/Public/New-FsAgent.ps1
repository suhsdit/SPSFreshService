Function New-FsAgent {
<#
.SYNOPSIS
    Creates an agent within FreshService
.DESCRIPTION
    The New-FsAgent function inputs a new agent into the FreshService domain
    *REQUIRED PARAMS* - FirstName, Email, Roles
.EXAMPLE
    New-FsAgent -FirstName 'John' -Email 'john.doe@contoso.com' . . . 
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
            [String]$FirstName,
        
        [Parameter(Mandatory=$false,
            Position=1)]
            [String]$LastName,
        
        [Parameter(Mandatory=$false,
            Position=2)]
            [String]$JobTitle,
        
        [Parameter(Mandatory=$false,
            Position=3)]
            [Int[]]$DeptIDs,
        
        [Parameter(Mandatory=$true,
            Position=4)]
            [String]$Email,
        
        [Parameter(Mandatory=$false,
            Position=6)]
            [Boolean]$SeeAssociatedTickets,
        
        [Parameter(Mandatory=$false,
            Position=7)]
            [Hashtable]$CustomFields,
        
        [Parameter(Mandatory=$false,
            Position=8)]
            [String]$TimeFormat,
        
        [Parameter(Mandatory=$false,
            Position=10)]
            [String]$TimeZone,
        
        [Parameter(Mandatory=$false,
            Position=11)]
            [Boolean]$Occasional,
        
        [Parameter(Mandatory=$true,
            Position=12)]
            [Hashtable[]]$Roles,
        
        [Parameter(Mandatory=$false,
            Position=13)]
            [String]$Signature,
        
        [Parameter(Mandatory=$false,
            Position=14)]
            [Int[]]$GroupIDs,
        
        [Parameter(Mandatory=$false,
            Position=15)]
            [Int[]]$MemeberOf,
        
        [Parameter(Mandatory=$false,
            Position=16)]
            [Int[]]$ObserverOf
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
        if (!($TimeFormat)) {
            $TimeFormat = '12h'
        }
        if (!($TimeZone)) {
            $TimeZone = 'Pacific Time (US & Canada)'
        }
    }
    Process{
        
        $Attributes = @{}
        if ($FirstName){
            $Attributes.Add('first_name', $($FirstName))
        }
        if ($LastName){
            $Attributes.Add('last_name', $($LastName))
        }
        if ($JobTitle){
            $Attributes.Add('job_title', $($JobTitle))
        }
        if ($Email){
            $Attributes.Add('email', $($Email))
        }
        if ($DeptIDs){
            $Attributes.Add('department_ids', $($DeptIDs))
        }
        if ($SeeAssociatedTickets){
            $Attributes.Add('can_see_all_tickets_from_associated_departments', $($SeeAssociatedTickets))
        }
        if ($CustomFields){
            $Attributes.Add('custom_fields', $($CustomFields))
        }
        if ($TimeFormat){
            $Attributes.Add('time_format', $($TimeFormat))
        }
        if ($TimeZone){
            $Attributes.Add('time_zone', $($TimeZone))
        }
        if ($Occasional){
            $Attributes.Add('occasional', $($Occasional))
        }
        if ($Roles){
            $Attributes.Add('roles', $($Roles))
        }
        if ($Signature){
            $Attributes.Add('signature', $($Signature))
        }
        if ($GroupIDs){
            $Attributes.Add('group_ids', $($GroupIDs))
        }
        if ($MemeberOf){
            $Attributes.Add('member_of', $($MemeberOf))
        }
        if ($ObserverOf){
            $Attributes.Add('observer_of', $($ObserverOf))
        }

        $Body = $Attributes | ConvertTo-Json

        Get-FreshServiceAPIResult -APIEndpoint "$($APIURL)/agents" -Body $Body -Method Post
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
Function Update-FsRequester {
<#
.SYNOPSIS
    Updates a requester within FreshService
.DESCRIPTION
    The Update-FsRequester function updates an existing requester into the FreshService domain
    *REQUIRED PARAMS* FirstName, UpdateID
.EXAMPLE
    Update-FsRequester -FirstName 'John' -LastName 'Hammond' -Description 'test description' . . .
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
        
        [Parameter(Mandatory=$false,
            Position=4)]
            [String]$PrimaryEmail,
        
        [Parameter(Mandatory=$false,
            Position=5)]
            [String[]]$SecondaryEmails,
        
        [Parameter(Mandatory=$false,
            Position=6)]
            [Bool]$SeeAssociatedTickets,
        
        [Parameter(Mandatory=$false,
            Position=7)]
            [Hashtable]$CustomFields,
        
        [Parameter(Mandatory=$false,
            Position=8)]
            [String[]]$TimeFormat,
        
        [Parameter(Mandatory=$false,
            Position=9)]
            [String[]]$TimeZone,

        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            Position=10)]
            [String]$UpdateID
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
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
        if ($PrimaryEmail){
            $Attributes.Add('primary_email', $($PrimaryEmail))
        }
        if ($SecondaryEmails){
            $Attributes.Add('secondary_emails', $($SecondaryEmails))
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
        if ($DeptIDs){
            $Attributes.Add('department_ids', $($DeptIDs))
        }

        $Body = $Attributes | ConvertTo-Json

        Get-FreshServiceAPIResult -APIEndpoint "$($APIURL)/requesters/$($UpdateID)" -Body $Body -Method 'PUT'
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
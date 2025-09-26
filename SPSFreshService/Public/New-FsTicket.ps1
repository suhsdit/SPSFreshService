Function New-FsTicket {
<#
.SYNOPSIS
    Creates a ticket within FreshService
.DESCRIPTION
    The New-FsTicket function inputs a new ticket into the FreshService domain
    *REQUIRED PARAMS* - Email, Subject, Status
.EXAMPLE
    New-FsTicket -Email 'john.doe@contoso.com' -Status '3' -Subject 'Projector Malfunction' . . .
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
            [String]$Email,
        
        [Parameter(Mandatory=$true,
            Position=1)]
            [String]$Subject,
        
        [Parameter(Mandatory=$false,
            Position=2)]
            [String[]]$CCEmails,
        
        [Parameter(Mandatory=$false,
            Position=3)]
            [Int]$DeptID,
        
        [Parameter(Mandatory=$false,
            Position=4)]
            [String]$Name,
        
        [Parameter(Mandatory=$false,
            Position=6)]
            [DateTime]$FRDueBy,
        
        [Parameter(Mandatory=$false,
            Position=7)]
            [Hashtable]$CustomFields,
        
        [Parameter(Mandatory=$false,
            Position=8)]
            [Int]$RequesterID,
        
        [Parameter(Mandatory=$false,
            Position=9)]
            [Int]$ResponderID,
        
        [Parameter(Mandatory=$false,
            Position=10)]
            [ValidateSet("Low","Medium","High","Urgent")]
            [Object]$Priority,
        
        [Parameter(Mandatory=$true,
            Position=11)]
            [ValidateSet("Open","Pending","Resolved","Closed","OnHold")]
            [Object]$Status,
        
        [Parameter(Mandatory=$false,
            Position=12)]
            [Int]$Source,
        
        [Parameter(Mandatory=$false,
            Position=13)]
            [String]$Type,
        
        [Parameter(Mandatory=$false,
            Position=14)]
            [String]$Description
    )

    Begin{
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI

        $StatusInt = $null
        switch ($Status) {
            Open     {$StatusInt = 2}
            Pending  {$StatusInt = 3}
            Resolved {$StatusInt = 4}
            Closed   {$StatusInt = 5}
            OnHold   {$StatusInt = 6}
        }

        $PriorityInt = $null
        switch ($Priority) {
            Low    {$PriorityInt = 1}
            Medium {$PriorityInt = 2}
            High   {$PriorityInt = 3}
            Urgent {$PriorityInt = 4}
        }
    }
    Process{

        $Attributes = @{}
        if ($Name){
            $Attributes.Add('name', $($Name))
        }
        if ($Subject){
            $Attributes.Add('subject', $($Subject))
        }
        if ($CCEmails){
            $Attributes.Add('cc_emails', $($CCEmails))
        }
        if ($Email){
            $Attributes.Add('email', $($Email))
        }
        if ($DeptID){
            $Attributes.Add('department_id', $($DeptID))
        }
        if ($Description){
            $Attributes.Add('description', $($Description))
        }
        if ($CustomFields){
            $Attributes.Add('custom_fields', $($CustomFields))
        }
        if ($FRDueBy){
            $Attributes.Add('fr_due_by', $($FRDueBy))
        }
        if ($RequesterID){
            $Attributes.Add('requester_id', $($RequesterID))
        }
        if ($ResponderID){
            $Attributes.Add('responder_id', $($ResponderID))
        }
        if ($StatusInt){
            $Attributes.Add('status', $($StatusInt))
        }
        if ($PriorityInt){
            $Attributes.Add('priority', $($PriorityInt))
        }
        if ($Source){
            $Attributes.Add('source', $($Source))
        }
        if ($Type){
            $Attributes.Add('type', $($Type))
        }

        $Body = $Attributes | ConvertTo-Json

        Get-FreshServiceAPIResult -APIEndpoint "$($APIURL)/tickets" -Body $Body -Method 'POST'
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
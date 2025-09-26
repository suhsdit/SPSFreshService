Function Update-FsTicket {
<#
.SYNOPSIS
    Updates a ticket within FreshService
.DESCRIPTION
    The Update-FsTicket function updates an existing ticket into the FreshService domain
    *REQUIRED PARAMS* UpdateID
.EXAMPLE
    Update-FsTicket -status '3' -UpdateID '12345680' . . .
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
        [Alias("UpdateID", "TicketID")] # Param was originally UpdateID, kept it as alias for compatibility with existing scripts.
            [String]$ID,

        [Parameter(Mandatory=$false)]
            [String]$Name,
        
        [Parameter(Mandatory=$false)]
            [String]$Subject,
        
        [Parameter(Mandatory=$false)]
            [String[]]$CCEmails,
        
        [Parameter(Mandatory=$false)]
            [Int]$DeptID,
        
        [Parameter(Mandatory=$false)]
            [String]$Email,
        
        [Parameter(Mandatory=$false)]
            [DateTime]$FRDueBy,
        
        [Parameter(Mandatory=$false)]
            [Hashtable]$CustomFields,
        
        [Parameter(Mandatory=$false)]
            [Int]$RequesterID,
        
        [Parameter(Mandatory=$false)]
            [Int]$ResponderID,
        
        [Parameter(Mandatory=$false)]
            [ValidateSet("Low","Medium","High","Urgent")]
            [Object]$Priority,
        
        [Parameter(Mandatory=$false)]
            [ValidateSet("Open","Pending","Resolved","Closed","OnHold")]
            [Object]$Status,
        
        [Parameter(Mandatory=$false)]
            [Int]$Source,
        
        [Parameter(Mandatory=$false)]
            [String]$Type,
        
        [Parameter(Mandatory=$false)]
            [String]$Description,
        
        [Parameter(Mandatory=$false)]
            [Int64]$GroupID
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
        if ($GroupID){
            $Attributes.Add('group_id', $($GroupID))
        }

        $Body = $Attributes | ConvertTo-Json

        Get-FreshServiceAPIResult -APIEndpoint "$($APIURL)/tickets/$($ID)" -Body $Body -Method 'PUT'
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
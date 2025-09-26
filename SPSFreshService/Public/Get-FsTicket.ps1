Function Get-FsTicket {
<#
.SYNOPSIS
    Gets one or more Tickets from FreshService
.DESCRIPTION
    The Get-FsTicket function gets tickets from your FreshService domain
.EXAMPLE
    Get-FsTicket -Status open
    Get all tickets with 'status: open'
.PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
    [CmdletBinding()] #Enable all the default paramters, including
    Param(
        [Parameter(Mandatory=$False)]
            [ValidateSet("Open","Pending","Resolved","Closed","OnHold")]
            [String[]]$Status,
        
        [Parameter(Mandatory=$False)]
            [ValidateSet("Low","Medium","High","Urgent")]
            [String[]]$Priority,

        [Parameter(Mandatory=$False)]
            [DateTime]$CreatedAt,

        [Parameter(Mandatory=$False)]
            [String[]]$Tag,

        [Parameter(Mandatory=$False)]
            [String[]]$AgentEmail,

        [Parameter(Mandatory=$False)]
            [String[]]$ID,
        [Parameter(Mandatory=$False)]
            [Int32]$Pages = 10000
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
        $APIEndpoint = "$($APIURL)/tickets"
        
        $StatusArray = @()
        foreach ($Stat in $Status) {
            switch ($Stat) {
                Open {$StatusArray += 2}
                Pending {$StatusArray += 3}
                Resolved {$StatusArray += 4}
                Closed {$StatusArray += 5}
                OnHold {$StatusArray += 6}
            }
        }

        $PriorityArray = @()
        foreach ($Prior in $Priority) {
            switch ($Prior) {
                Low {$PriorityArray += 1}
                Medium {$PriorityArray += 2}
                High {$PriorityArray += 3}
                Urgent {$PriorityArray += 4}
            }
        }
    } Process {
        if ($ID) {
            $APIEndpoint += "/$($ID)"
            Write-Verbose "so far after params and regex: $($APIEndpoint)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'ticket' -Paginate $false -Method 'Get'
        }
        else {
            $Agent = Get-FsAgent -Email $AgentEmail
            $AgentID = $Agent.id
            
            if ($StatusArray -or $PriorityArray -or $AgentEmail -or $CreatedAt -or $Tag) {$APIEndpoint += "/filter?query=`""}
            if ($StatusArray) {
                foreach ($Number in $StatusArray) {
                    $APIEndpoint += "status:$($Number) OR "
                }
                $APIEndpoint = $APIEndpoint -replace "\s.{2}\s$"," AND "
            } 
            if ($PriorityArray) {
                foreach ($Number in $PriorityArray) {
                    $APIEndpoint += "priority:$($Number) OR "
                }
                $APIEndpoint = $APIEndpoint -replace "\s.{2}\s$"," AND "
            }
            if ($Tag) {$APIEndpoint += "tag:$($Tag) AND "} 
            if ($CreatedAt) {$APIEndpoint += "created_at:$($CreatedAt) AND "} 
            if ($AgentEmail) {$APIEndpoint += "agent_id:$($AgentID) AND "}
            $APIEndpoint = $APIEndpoint -replace "\s.{3}\s$","`""
            Write-Verbose "so far after params and regex: $($APIEndpoint)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'tickets' -Paginate $true -Pages $Pages -Method 'Get'
        } 
    } End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
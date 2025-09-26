Function Update-FsAgentGroup {
<#
.SYNOPSIS
    Updates an agent group within FreshService
.DESCRIPTION
    The Update-FsAgentGroup function updates an agent group in the FreshService domain
    *REQUIRED FIELDS* - Name, UpdateID
.EXAMPLE
    Update-FsAgentGroup -Name 'John' -Description 'test description' . . .
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
            [String]$UnassignedFor,

        [Parameter(Mandatory=$false,
            Position=3)]
            [Int]$BusinessHourID,

        [Parameter(Mandatory=$false,
            Position=4)]
            [Int]$EscalateTo,

        [Parameter(Mandatory=$false,
            Position=5)]
            [Array]$Members,

        [Parameter(Mandatory=$false,
            Position=6)]
            [Array]$Observers,

        [Parameter(Mandatory=$false,
            Position=7)]
            [Boolean]$Restricted,

        [Parameter(Mandatory=$false,
            Position=8)]
            [Array]$Leaders,

        [Parameter(Mandatory=$false,
            Position=9)]
            [Boolean]$ApprovalRequired,

        [Parameter(Mandatory=$false,
            Position=10)]
            [Boolean]$AutoTicketAssign,

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
        if ($Description){   
            $Attributes.Add('description', $($Description))
        }
        if ($AgentIDs){
            $Attributes.Add('agent_ids', $($AgentIDs))
        }
        if ($UnassignedFor){
            $Attributes.Add('unassigned_for', $($UnassignedFor))
        }
        if ($BusinessHourID){
            $Attributes.Add('business_hours_id', $($BusinessHourID))
        }
        if ($EscalateTo){
            $Attributes.Add('escalate_to', $($EscalateTo))
        }
        if ($Members){
            $Attributes.Add('members', $($Members))
        }
        if ($Observers){
            $Attributes.Add('observers', $($Observers))
        }
        if ($Restricted){
            $Attributes.Add('restricted', $($Restricted))
        }
        if ($Leaders){
            $Attributes.Add('leaders', $($Leaders))
        }
        if ($ApprovalRequired){
            $Attributes.Add('approval_required', $($ApprovalRequired))
        }
        if ($AutoTicketAssign){
            $Attributes.Add('auto_ticket_assign', $($AutoTicketAssign))
        }

        $Body = $Attributes | ConvertTo-Json

        Get-FreshServiceAPIResult -APIEndpoint "$($APIURL)/groups/$($UpdateID)" -Body $Body -Method 'PUT'
    }
    End{
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
Function Get-FsDepartment {
<#
.SYNOPSIS
    Gets one or more departments from FreshService
.DESCRIPTION
    The Get-FsDepartment function gets departments from your FreshService domain
.EXAMPLE
    Get-FsDepartment
    Get all departments
.PARAMETER
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>
    [CmdletBinding()] #Enable all the default paramters, including
    Param(
        [Parameter(Mandatory=$false,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
            [String]$ID,

        [Parameter(Mandatory=$false,
            Position=1)]
            [String]$Name,

        [Parameter(Mandatory=$false,
            Position=1)]
            [String]$Domain
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.InvocationName) with $($PsCmdlet.ParameterSetName) parameterset..."
        Write-Verbose -Message "Parameters are $($PSBoundParameters | Select-Object -Property *)"
        Connect-FreshServiceAPI
        $APIEndpoint = "$($APIURL)/departments"
    } Process {
        if ($ID) {
            write-verbose -Message "Using parameter"
            $APIEndpoint = "$($APIEndpoint)/$($ID)"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'departments' -Paginate $false
        } if ($Name) {
            $APIEndpoint = "$($APIEndpoint)?query=name:'$([uri]::EscapeDataString($Name))'"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'departments' -Paginate $false
        } if ($Domain) {
            $DeptsHT = @{}
            $Depts = Get-FsDepartment
            foreach ($Dept in $Depts) {
                if ($Dept.domains[0]) {
                    $DeptsHT[$Dept.Domains[0]] = $Dept
                }
            }
            Write-Verbose "Hash of depts is: $($DeptsHT.Keys)"
            $DeptName = $DeptsHT[$Domain].Name
            Write-Verbose "Deptname is: $Deptname"
            $APIEndpoint = "$($APIEndpoint)?query=name:'$([uri]::EscapeDataString($DeptName))'"
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'departments' -Paginate $false -Method 'Get'
        } else {
            Get-FreshServiceAPIResult -APIEndpoint $APIEndpoint -PrimaryObject 'departments' -Paginate $true -Method 'Get'
        }
    } End {
        Write-Verbose -Message "Ending $($MyInvocation.InvocationName)..."
    }
}
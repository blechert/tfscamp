<#
.\MD_Generator.ps1 -Uri 'https://dev.azure.com/SHS-IT-AlmDev/General' -PAT 'jdnspkmqurssuscmxaisruwnvs6s6gy3poipvptpiumvmkny4gha' -WiIds @(66,67,68)
#>
[CmdletBinding()]
[OutputType([string])]
param(
    # Array of WiId
    [Parameter(Mandatory=$true, ValueFromPipeline)]
        [int[]] $WiIds,
    # https://dev.azure.com/{organization}/{project}
    [Parameter(Mandatory=$true)]
        [string] $Uri,
    # Access token
    [Parameter(Mandatory=$true)]
        [string] $PAT
)

Begin {
    function Get-WiInfo {
        [OutputType([PSCustomObject])]
        param (
            [Parameter(Mandatory=$true)]
                [string] $Uri,
            [Parameter(Mandatory=$true)]
                [string] $PAT
        )

        Begin {
            if($PAT -ne '') {
                $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f '',$PAT)))
            } else {
                Write-Error "WTF: Wo ist der PAT"
            }
        }

        Process {
            #Write-Host $Uri
            return Invoke-WebRequest -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Uri $Uri -ContentType 'application/json' -Method Get | ConvertFrom-Json
        }

        End {}
    }
}

Process {
    foreach($wi in $WiIds) {
        $res = Get-WiInfo -Uri ("{0}/_apis/wit/workitems/{1}?api-version={2}" -f $Uri, $wi, '5.1') -PAT $PAT
        $res.fields.'System.Description'
        $res.fields.'System.Title'
        $res.Id
    }
}

End {}


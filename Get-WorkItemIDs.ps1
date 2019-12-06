#Requires -version 4
<#
.SYNOPSIS
    Retrive WorkItem data from PR-IDs
.DESCRIPTION
.NOTES
.COMPONENT
.EXAMPLE
.\Get-WorkItemIDs.ps1 -PRIDs @(1,2,3)
#>
[CmdletBinding()]
[OutputType([string])]
param(
    [Parameter(Mandatory=$true, ValueFromPipeline)]
        [int[]] $PRIDs
)

Begin {
    $IDs = New-Object System.Collections.ArrayList;

    function Get-WIIDs {
        [OutputType([PSCustomObject])]
        param (
            # Azure DevOps Rest Api Call
            [Parameter(Mandatory=$true)]
                [string] $Uri,
            # Access Token
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
            Write-Verbose ("Connect to: {0}" -f $Uri)
            return Invoke-WebRequest -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Uri $Uri -ContentType 'application/json' -Method Get | ConvertFrom-Json
        }

        End {}
    }  
}

Process {
    $devops_baseUrl = $env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI
    $devops_team = $env:SYSTEM_TEAMPROJECT
    $devops_repo = $env:BUILD_REPOSITORY_NAME
    $pat =  $Env:SYSTEM_ACCESSTOKEN

    foreach($PRID in $PRIDs) {
        $request_uri = ("{0}{1}/_apis/git/repositories/{2}/pullRequests/{3}/workitems?api-version={4}" -f $devops_baseUrl,$devops_team,$devops_repo,$PRID,'5.1')
        $res = Get-WIIDs -Uri $request_uri -PAT $pat

        foreach ($value in $res.value)  
        {
            $IDs.Add($value.'id') | Out-Null
        }        
    }
}

End {
    return $IDs;
}

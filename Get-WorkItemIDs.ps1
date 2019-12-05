#Requires -version 4
<#
.SYNOPSIS
    Retrive WorkItem data from PR-IDs
.DESCRIPTION
.NOTES
.COMPONENT
.EXAMPLE
.\Get-WorkItemIDs.ps1 -Uri 'https://dev.azure.com/{organisation}}/{project}' -PAT '<YourToken>' -PRIDs @(1,2,3)
#>
[CmdletBinding()]
[OutputType([string])]
param(
    [Parameter(Mandatory=$true, ValueFromPipeline)]
        [int[]] $PRIDs,
    [Parameter(Mandatory=$true)]
        [string] $Uri,
    [Parameter(Mandatory=$true)]
        [string] $PAT
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
    foreach($PRID in $PRIDs) {
        $request_uri = ("{0}/_apis/git/repositories/{1}/pullRequests/{2}/workitems?api-version={3}" -f $Uri, $env:BUILD_REPOSITORY_NAME, $PRID, '5.1')
        $res = Get-WIIDs -Uri $request_uri -PAT $PAT

        foreach ($value in $res.value)  
        {
            $r = $IDs.Add($value.'id');
        }        
    }
}

End {
    return $IDs;
}
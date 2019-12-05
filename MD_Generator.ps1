#Requires -version 4

<#
.SYNOPSIS
    Retrive WorkItem data
.DESCRIPTION
.NOTES
.COMPONENT
.EXAMPLE
.\MD_Generator.ps1 -Uri 'https://dev.azure.com/{organisation}}/{project}' -PAT '<YourToken>' -WiIds @(66,67,68)
#>
[CmdletBinding()]
[OutputType([string])]
param(
    # Array of WorkItem IDs
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

    function Format-MdOutput{
        Param (
            # DatatTable to export
            [Parameter(Mandatory=$true, Position=0)]
                [System.Data.DataTable] $ReleaseNotes
        )

        Begin {
            Write-Output ("#ReleaseNotes`n`n")
        }
        Process{
            foreach($row in $ReleaseNotes.Rows) {
                Write-Output ("## #{0}`t{1}`n{2}" -f $row.Id, $row.Title, $row.Description)
            }
        }
        End {}
    }

    #Create Table object
    $ReleaseNotes = New-Object System.Data.DataTable 'ReleaseNotes'
    
    #Define Columns
    $col1 = New-Object System.Data.DataColumn ID,([Int])
    $col2 = New-Object System.Data.DataColumn Title,([string])
    $col3 = New-Object System.Data.DataColumn Description,([string])
    
    $ReleaseNotes.columns.add($col1)
    $ReleaseNotes.columns.add($col2)
    $ReleaseNotes.columns.add($col3)
}

Process {
    foreach($wi in $WiIds) {
        $res = Get-WiInfo -Uri ("{0}/_apis/wit/workitems/{1}?api-version={2}" -f $Uri, $wi, '5.1') -PAT $PAT
        Write-Verbose ("ID : {0}, Title: {1}, Description: {2}" -f $res.Id, $res.fields.'System.Title', $res.fields.'System.Description')

        #Create a row
        $row = $ReleaseNotes.NewRow()

        #Enter data in the row
        $row.Id = $res.Id
        $row.Title = $res.fields.'System.Title'
        $row.Description = $res.fields.'System.Description'

        #Add the row to the table
        $ReleaseNotes.Rows.Add($row)
    }
}

End {
    Format-MdOutput $ReleaseNotes
}


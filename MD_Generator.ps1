#Requires -version 4

<#
.SYNOPSIS
    Retrive WorkItem data
.DESCRIPTION
    From the named WorkItems the fields ID, Title, and Description will be exported in MarkDown format
    
    ## #{ID}    {Title} 
    {Description}

.NOTES
.COMPONENT
.EXAMPLE
.\MD_Generator.ps1 -Uri 'https://dev.azure.com/{organisation}}/{project}' -PAT '<YourToken>' -WiIds @(66,67,68)
@(66,67,68) | .\MD_Generator.ps1 -Uri 'https://dev.azure.com/{organisation}}/{project}' -PAT '<YourToken>' | Out-File MyReleaseNotes.MD

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
    [Parameter(Mandatory=$false)]
        [string] $PAT = ''
)

Begin {
    function Get-WiData {
        [OutputType([PSCustomObject])]
        param (
            # Azure DevOps Rest Api Call
            [Parameter(Mandatory=$true)]
                [string] $Uri,
            # Access Token
            [Parameter(Mandatory=$false)]
                [string] $PAT = ''
        )

        Begin {
            if($PAT -ne '') {
                $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f '',$PAT)))
                $header = @{ Authorization = ("Basic {0}" -f $base64AuthInfo) }
            } elseif ($env:SYSTEM_ACCESSTOKEN -ne ''){
                $header = @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" }
            } else {
                Write-Error "WTF: Wo ist der PAT"
                exit -1
            }
        }

        Process {
            Write-Verbose ("Connect to: {0}" -f $Uri)
            return Invoke-WebRequest -Headers $header -Uri $Uri -ContentType 'application/json' -Method Get | ConvertFrom-Json
        }

        End {}
    }

    function Format-MdOutput{
        [OutputType([string])]
        Param (
            # DatatTable to export
            [Parameter(Mandatory=$true, Position=0)]
                [System.Data.DataTable] $ReleaseNotes
        )

        Begin {
            Write-Output ("#ReleaseNotes {0}`n`n" -f $env:Build_BuildNumber)
        }

        Process{
            foreach($row in $ReleaseNotes.Rows) {
                Write-Output ("## #{0}`t{1}`n{2}`n" -f $row.Id, $row.Title, $row.Description)
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
 
    # Add Columns to table
    $ReleaseNotes.columns.add($col1)
    $ReleaseNotes.columns.add($col2)
    $ReleaseNotes.columns.add($col3)
}

Process {
    # Either will get the data from one Wi when piped or from all Wis in the array
    foreach($wi in $WiIds) {
        $res = Get-WiData -Uri ("{0}/_apis/wit/workitems/{1}?api-version={2}" -f $Uri, $wi, '5.1') -PAT $PAT
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
    # Will return the whole table with all Wi data, no matter if piped or array as input
    Format-MdOutput $ReleaseNotes
}
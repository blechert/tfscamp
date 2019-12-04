## Wrapper for calling Azure DevOps endpoints

Function:

```ps1
Function Invoke-DevOpsRequest
{
    Param([Parameter(Mandatory=$true)]$uri)

    $pat = (Get-Content .\azure-devops-secrets.json | ConvertFrom-Json).accesstoken
    $encPat = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$pat"))
    $header = @{ Authorization = "Basic $encPat" }

    try 
    {
        $response = Invoke-WebRequest -Uri $uri -Headers $header
        return $response.Content | ConvertFrom-Json
    }
    catch
    {
        return $null
    }
}
```

Usage (Delivers the last five iterations in `TeamSprints\`:

```ps1
$devops_org = 'Awesome_Org'
$devops_team = 'Awesome_Team'
$devops_iterationcond = 'TeamSprints\'
$devops_iterationtop = 5
$url_iterations = "https://analytics.dev.azure.com/$devops_org/$devops_team/_odata/v2.0/Iterations?`$top={0}&`$filter=startswith(IterationPath, '{1}') and StartDate lt now()&`$orderby=StartDate desc"
$iterations = Invoke-DevOpsRequest -uri ($url_iterations -f $devops_iterationtop,$devops_iterationcond)
```


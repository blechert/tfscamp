$RELEASE_RELEASEID = 5316
$BUILD_SOURCEVERSION = "be56cc84009adfaa7f98b4eb3a5dd0743b0facae"

$devops_org = '***REMOVED***'
$devops_team = '***REMOVED***'
$devops_releaseDef = 9
$devops_releaseEnvDef = 84

$arg_currentReleaseId = $RELEASE_RELEASEID
$arg_currentBuildVersion = $BUILD_SOURCEVERSION
$url_releases = "https://vsrm.dev.azure.com/$devops_org/$devops_team/_apis/release/releases?api-version=5.1&definitionId=$devops_releaseDef&`$expand=environments&definitionEnvironmentId=$devops_releaseEnvDef"

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

(Invoke-DevOpsRequest -uri $url_releases).value | 
    Select-Object `
        id,name,status,
        @{n='env'; e={ ($_.environments | Where-Object { $_.definitionEnvironmentId -eq $devops_releaseEnvDef -and $_.status -eq 'succeeded' }) }}

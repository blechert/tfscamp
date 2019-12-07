#Requires -version 4
<#
.SYNOPSIS
    Retrive Pull Request IDs between two azure devops releases
.DESCRIPTION
.NOTES
.COMPONENT
.EXAMPLE
.\extract-pr.ps1
#>

# Azure DevOps Properties
$devops_team = $env:SYSTEM_TEAMPROJECT
$devops_releaseDef = $env:RELEASE_DEFINITIONID
$devops_releaseEnvDef = $env:RELEASE_DEFINITIONENVIRONMENTID
$devops_baseUrl = $env:SYSTEM_TEAMFOUNDATIONSERVERURI

# Required arguments to query the API
$arg_currentReleaseId = $env:RELEASE_RELEASEID
$arg_currentBuildVersion = $env:BUILD_SOURCEVERSION
$arg_currentArtifactName = $env:RELEASE_PRIMARYARTIFACTSOURCEALIAS
$url_releases = "$devops_baseUrl/$devops_team/_apis/release/releases?api-version=5.1&definitionId=$devops_releaseDef&`$expand=environments,artifacts&definitionEnvironmentId=$devops_releaseEnvDef"

# Perform a request to the Azure DevOps API
Function Invoke-DevOpsRequest
{
    Param([Parameter(Mandatory=$true)]$uri)

    # https://docs.microsoft.com/en-us/azure/devops/pipelines/build/variables?view=azure-devops&tabs=yaml#systemaccesstoken
    $pat =  $Env:SYSTEM_ACCESSTOKEN
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

# Extract the deployed environment from the API response
Function Get-Environment
{
    Param([Parameter(Mandatory=$true, ValueFromPipeline)]$environments)

    return $environments |
        Where-Object { `
                $_.definitionEnvironmentId -eq $devops_releaseEnvDef `
                    -and $_.status -eq 'succeeded' `
            }[0] | 
        Select-Object `
            id,name,status
}

# Extract the commit SHA hash from the API response
Function Get-BuildVersion
{
    Param([Parameter(Mandatory=$true, ValueFromPipeline)]$artifacts)

    return ($artifacts |
        Where-Object { $_.alias -eq $arg_currentArtifactName } |
        Select-Object -First 1)[0].definitionReference.sourceVersion.id
}

# Request past releases and filter for the release right before the current one
$lastRelease = (Invoke-DevOpsRequest -uri $url_releases).value | 
    Select-Object `
        id,name,status,
        @{n='env'; e={ ($_.environments | Get-Environment) }},
        @{n='commit'; e={ ($_.artifacts | Get-BuildVersion) }} |
    Where-Object { $_.id -lt $arg_currentReleaseId } |
    Select-Object -First 1

# git commit SHA hashes
$sourceref = $lastRelease.commit
$targetref = $arg_currentBuildVersion

# Create log
$gitlog = Invoke-Expression "git --no-pager log --pretty=format:""%s"" --grep='Merged PR' $sourceref..$targetref"

# Extract pull request IDs from the log output
return $gitlog.split("`n") | Select-String -Pattern "^Merged PR ([0-9]+):" -List | 
    Where-Object { $_.matches.Success -eq $true } |
    Foreach-Object { $_.matches.groups[1].Value } |
    Sort-Object | Get-Unique

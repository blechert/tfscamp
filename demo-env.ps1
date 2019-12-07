# these environment variables are required to run the scripts.
# this is NOT NEEDED for use in relase pipelines!

$env:SYSTEM_TEAMFOUNDATIONSERVERURI = "https://vsrm.dev.azure.com/**your organization**/"
$env:SYSTEM_TEAMPROJECT = "**your team project**"
$env:RELEASE_RELEASEID = 5160
$env:RELEASE_DEFINITIONID = 9
$env:RELEASE_DEFINITIONENVIRONMENTID = 84
$env:BUILD_SOURCEVERSION = "ae143356b36b195bb2f0a53fece9bc2f0011986d"
$env:RELEASE_PRIMARYARTIFACTSOURCEALIAS = "**artifact name**"
$env:BUILD_REPOSITORY_NAME = "**repository name**"
$env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI = "https://dev.azure.com/**your organization**/"

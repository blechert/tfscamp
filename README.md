Some awesome scripts and other stuff created at the TFS Camp 2019 in Bad Ems.

Github is the future. :star: :heart:

## Create Release Note from Relases

Three scripts:

- [Create Markdown Changelog from Azure Boards WorkItem IDs](MD_Generator.ps1)
- [Extract Pull Request IDs between two Release deploys](extract-pr.ps1)
- [Extract Work Item IDs from Pull Requests](Get-WorkItemIDs.ps1)

Workflow:

- Use the current release infos to get the prevoius release for the same environment
- Use `git log` to get all Merge Requests between the releases
- Extract the Work Item IDs from the Pull Requests
- Generate markdown text as a readme

TODO:

- Create a new Wiki page from the markdown text

Usage:

```ps1
# needs the git repo as current dir
cd sourcecode-repo
# set the environment vars, only needed for demos
..\tfscamp\demo-env.ps1
# set a personal access token, only needed for demos
$env:SYSTEM_ACCESSTOKEN="XXXXXXXXXXXXXXXXXXXXXX"
# execute the scripts
..\tfscamp\extract-pr.ps1 | ..\tfscamp\Get-WorkItemIDs.ps1 | ..\tfscamp\MD_Generator.ps1
```

## Resources

- [Snippet to access the Azure DevOps API via PowerShell](azure-and-powershell.md)

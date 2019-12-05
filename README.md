Some awesome scripts and other stuff created at the TFS Camp 2019 in Bad Ems.

Github is the future. :star: :heart:

## Scripts

- [Create Markdown Changelog from Azure Boards WorkItem IDs](MD_Generator.ps1)
- [Extract Pull Request IDs between two Release deploys](extract-pr.ps1)
    - Works hardcoded
    - Needs a git binary and multiple informations from the build agent (see hardcoded "env" vars)
    - Needs to be executed in the git work folder
    - Example usage: `$env:SYSTEM_ACCESSTOKEN="XXXX"; ..\tfscamp\extract-pr.ps1`

## Resources

- [Snippet to access the Azure DevOps API via PowerShell](azure-and-powershell.md)

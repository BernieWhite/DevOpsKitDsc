# DevOps Kit for Dsc

This DevOps Kit for Desired State Configuration (DOKDsc) aims to provide IT Pros with tools and documentation to easily adopt a DevOps model for deploying and managing Desired State Configuration (DSC).

DSC already provides the tools for IT Pros to automate the configuration of Windows or Linux to stand-up a fully running workload. Application Lifecycle Management (ALM) tools such as Visual Studio Team Services (VSTS) also provide features such as requirements tracking, version control and release management.

| AppVeyor (Windows) | Codecov (Windows) |
| --- | --- |
| [![av-image][]][av-site] | [![cc-image][]][cc-site] |

[av-image]: https://ci.appveyor.com/api/projects/status/29gj31o96ajd2ars
[av-site]: https://ci.appveyor.com/project/BernieWhite/devopskitdsc
[cc-image]: https://codecov.io/gh/BernieWhite/DevOpsKitDsc/branch/master/graph/badge.svg
[cc-site]: https://codecov.io/gh/BernieWhite/DevOpsKitDsc

## Disclaimer

This project is to be considered a **proof-of-concept** and **not a supported Microsoft product**.

## Modules

The following modules are included in this repository.

| Module       | Description | Latest version |
| ------       | ----------- | -------------- |
| DevOpsKitDsc | Automate releases of Desired State Configuration configurations | [v0.1.0][psg-dokdsc] |

[psg-dokdsc]: https://www.powershellgallery.com/packages/DevOpsKitDsc

## Getting started

Please see getting started documentation [here][getting-started].

[getting-started]: docs/getting-started.md

### Getting the module

- Install from PowerShellGallery.com

```powershell
# Install the module
Install-Module -Name 'DevOpsKitDsc';
```

- Save for offline use from PowerShellGallery.com

```powershell
# Save the DevOpsKitDsc module, in the .\modules directory
Save-Module -Name 'DevOpsKitDsc' -Path '.\modules';
```

### Getting Visual Studio Code integration

- Install extension (preview) from visualstudio.com

```powershell
# Install the extension
code --install-extension bewhite.dokd-vscode-preview
```

### Building a cloned git repository

```powershell
# Use git to clone the repository
git clone https://github.com/BernieWhite/DevOpsKitDsc-samples.git;

cd .\DevOpsKitDsc-samples

# Restore dependency modules to the workspace
Restore-DOKDscModule;

# Build all collections
Invoke-DOKDscBuild;
```

## Commands

- [Initialize-DOKDsc](/docs/commands/en-US/Initialize-DOKDsc.md)
- [Register-DOKDscNode](/docs/commands/en-US/Register-DOKDscNode.md)
- [Import-DOKDscNodeConfiguration](/docs/commands/en-US/Import-DOKDscNodeConfiguration.md)
- [Invoke-DOKDscBuild](/docs/commands/en-US/Invoke-DOKDscBuild.md)
- [New-DOKDscCollection](/docs/commands/en-US/New-DOKDscCollection.md)
- [Publish-DOKDscCollection](/docs/commands/en-US/Public-DOKDscCollection.md)
- [Get-DOKDscCollection](/docs/commands/en-US/Get-DOKDscCollection.md)
- [Import-DOKDscWorkspaceSetting](/docs/commands/en-US/Import-DOKDscWorkspaceSetting.md)
- [Set-DOKDscWorkspaceOption](/docs/commands/en-US/Set-DOKDscWorkspaceOption.md)
- [Get-DOKDscWorkspaceOption](/docs/commands/en-US/Get-DOKDscWorkspaceOption.md)
- [Add-DOKDscModule](/docs/commands/en-US/Add-DOKDscModule.md)
- [Get-DOKDscModule](/docs/commands/en-US/Get-DOKDscModule.md)
- [Publish-DOKDscModule](/docs/commands/en-US/Publish-DOKDscModule.md)
- [Restore-DOKDscModule](/docs/commands/en-US/Restore-DOKDscModule.md)

## Maintainers

- [Bernie White](https://github.com/BernieWhite)

## License

This project is [licensed under the MIT License](LICENSE).
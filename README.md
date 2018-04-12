# DevOps Kit for Dsc

This DevOps Kit for Desired State Configuration (DOKD) aims to provide IT Pros with tools and documentation to easily adopt a DevOps model for deploying and managing Desired State Configuration (DSC).

DSC already provides the tools for IT Pros to automate the configuration of Windows or Linux to stand-up a fully running workload. Application Lifecycle Management (ALM) tools such as Visual Studio Team Services (VSTS) also provide features such as requirements tracking, version control and release management.

| AppVeyor (Windows)       | Codecov (Windows) |
| ------------------       | ----------------- |
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
| DevOpsKitDsc | Automate releases of Desired State Configuration configurations | [![psg-dokdsc-version-badge][]][psg-dokdsc] [![psg-dokdsc-installs-badge][]][psg-dokdsc] |

## Features

- [DevOps](docs/feature-details.md#devops)
- [Collections](docs/feature-details.md#collections)
  - Group configuration and nodes into collections that can be built together.
- [Build](docs/feature-details.md#build)
  - Restore module dependencies.
  - Build only changed nodes with incremental build.
  - Build documentation together with DSC configurations.
- [Node configuration data](docs/feature-details.md#node-configuration-data)
  - Use flat configuration data structure for a single node.
  - Use your choice of PSD1 or JSON files for storing node data.
- [Release](docs/feature-details.md#release)
  - Package configurations and resource modules ready for a local pull server or Azure Automation Service.

## Getting started

### Getting the module

- Install from [PowerShell Gallery][psg-dokdsc]

```powershell
# Install the module
Install-Module -Name 'DevOpsKitDsc';
```

- Save for offline use from PowerShell Gallery

```powershell
# Save the DevOpsKitDsc module, in the .\modules directory
Save-Module -Name 'DevOpsKitDsc' -Path '.\modules';
```

### Getting Visual Studio Code integration

- Install extension (preview) from [Visual Studio Marketplace][vsm-dokd-vscode]

```powershell
# Install the extension
code --install-extension bewhite.dokd-vscode-preview
```

### Building a cloned git repository

Get a sample configuration repository and build the configurations.

```powershell
# Use git to clone the repository
git clone https://github.com/BernieWhite/DevOpsKitDsc-samples.git;

cd .\DevOpsKitDsc-samples

# Restore dependency modules to the workspace
Restore-DOKDscModule;

# Build all collections
Invoke-DOKDscBuild;
```

### Detailed instructions

For detailed instructions please see getting started documentation [here][getting-started].

## Commands

- [Initialize-DOKDsc](/docs/commands/en-US/Initialize-DOKDsc.md)
- [Register-DOKDscNode](/docs/commands/en-US/Register-DOKDscNode.md)
- [Import-DOKDscNodeConfiguration](/docs/commands/en-US/Import-DOKDscNodeConfiguration.md)
- [Invoke-DOKDscBuild](/docs/commands/en-US/Invoke-DOKDscBuild.md)
- [New-DOKDscCollection](/docs/commands/en-US/New-DOKDscCollection.md)
- [Publish-DOKDscCollection](/docs/commands/en-US/Public-DOKDscCollection.md)
- [Get-DOKDscCollection](/docs/commands/en-US/Get-DOKDscCollection.md)
- [Set-DOKDscCollectionOption](/docs/commands/en-US/Set-DOKDscCollectionOption.md)
- [Import-DOKDscWorkspaceSetting](/docs/commands/en-US/Import-DOKDscWorkspaceSetting.md)
- [Set-DOKDscWorkspaceOption](/docs/commands/en-US/Set-DOKDscWorkspaceOption.md)
- [Get-DOKDscWorkspaceOption](/docs/commands/en-US/Get-DOKDscWorkspaceOption.md)
- [Add-DOKDscModule](/docs/commands/en-US/Add-DOKDscModule.md)
- [Get-DOKDscModule](/docs/commands/en-US/Get-DOKDscModule.md)
- [Publish-DOKDscModule](/docs/commands/en-US/Publish-DOKDscModule.md)
- [Restore-DOKDscModule](/docs/commands/en-US/Restore-DOKDscModule.md)

## Related projects

| Project name       | Description |
| ------             | ----------- |
| [DevOpsKitDsc-vscode](https://github.com/BernieWhite/DevOpsKitDsc-vscode) | A Visual Studio Code extension for DOKD |
| [DevOpsKitDsc-samples](https://github.com/BernieWhite/DevOpsKitDsc-samples) | A sample DOKD repository |
| [PSDocs](https://github.com/BernieWhite/PSDocs) | A PowerShell module to generate markdown from pipeline objects |

## Maintainers

- [Bernie White](https://github.com/BernieWhite)

## License

This project is [licensed under the MIT License](LICENSE).

[psg-dokdsc]: https://www.powershellgallery.com/packages/DevOpsKitDsc
[psg-dokdsc-version-badge]: https://img.shields.io/powershellgallery/v/DevOpsKitDsc.svg
[psg-dokdsc-installs-badge]: https://img.shields.io/powershellgallery/dt/DevOpsKitDsc.svg
[vsm-dokd-vscode]: https://marketplace.visualstudio.com/items?itemName=bewhite.dokd-vscode-preview
[getting-started]: docs/getting-started.md

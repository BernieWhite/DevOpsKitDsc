# Getting started

## Workspace overview

The _DevOps Kit for Dsc_ uses a workspace to store reusable configuration information. A workspace can be any directory local or remote with read/write access.

An example of the workspace folder structure is shown below.

- _root_
  - `.dokd` - contains workspace `settings.json`
  - `build` - contains built `.mof` files
  - `nodes` - contains node data `.psd1` files
  - `src`
    - `SharePoint` - contains SharePoint server configuration scripts

## Create a workspace

To create a workspace use the `Initialize-DOKDsc` cmdlet (`dokd-init` for short). For a list of cmdlet options see [Initialize-DOKDsc](/docs/commands/en-US/Initialize-DOKDsc.md).

```powershell
# Create a new workspace in the current path
Initialize-DOKDsc;
```

See [Create a collection](getting-started.md#Create_a_collection) for next steps.

## Restore dependencies

If you already have a workspace stored in a source control system you may want to just restore dependencies to your local copy.

Module dependencies are restored with the `Restore-DOKDscModule` cmdlet (`dokd-restore` for short). For a list of cmdlet options see [Restore-DOKDscModule](/docs/commands/en-US/Restore-DOKDscModule.md).

```powershell
# Use git to clone the repository
git clone https://github.com/BernieWhite/DevOpsKitDsc-samples.git;

cd .\DevOpsKitDsc-samples

# Restore dependency modules to the workspace in the current path
Restore-DOKDscModule;
```

## Create a collection

After workspace is established the next step is to create a collection.

A collection allows you to associate a configuration script and the nodes that will be configured. Multiple collections can exist within a single workspace and may be used to seperate environments such as _Test_ / _Production_ or diffent workloads such as _SQL_ / _SharePoint_ depeneding on your needs.

Create a new configuration named `Production`. A new configuration script will be created by default at `src\Configuration\Production.ps1`.

```powershell
# Create a configuration named Production
New-DOKDscCollection -Name 'Production';
```

Create a new configuration named `Production` using an existing configuration script at `src\Configuration\Production.ps1`.

```powershell
New-DOKDscCollection -Name 'Production' -Path '.\src\Configuration\Production.ps1'
```

## Build a collection

After a configuration script and nodes have been defined, the configuration can be built using the `Invoke-DOKDscBuild` cmdlet.

```powershell
# Build all collections. To build a specific collection use the -Name parameter
Invoke-DOKDscBuild;
```

After the collection is built, .mof files will be output in the `.\build` directory.

## Full examples

### Building a new DSC configuration

```powershell
# Create a workspace in the current working path
Initialize-DOKDsc;

# Add a dependency module
Add-DOKDscModule -ModuleName 'SharePointDsc' -ModuleVersion '1.8.0.0';

# Create a collection
New-DOKDscCollection 'SharePoint';

# Build all collections
Invoke-DOKDscBuild;
```

### Building a cloned git repository

```powershell
# Use git to clone the repository
git clone https://github.com/BernieWhite/DevOpsKitDsc-example.git;

cd .\DevOpsKitDsc-example

# Restore dependency modules to the workspace
Restore-DOKDscModule;

# Build all collections
Invoke-DOKDscBuild;
```
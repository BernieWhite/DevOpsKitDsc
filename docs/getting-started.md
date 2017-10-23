# Getting started

## Create a workspace

The _DevOps Kit for Dsc_ uses a workspace to store reusable configuration information. A workspace can be any directory local or remote with read/write access.

An example of the workspace folder structure is shown below.

- _root_
  - `.dokd` - contains workspace `settings.json`
  - `build` - contains built `.mof` files
  - `nodes` - contains node data `.psd1` files
  - `src`
    - `SharePoint` - contains SharePoint server configuration scripts

To create a workspace use the `Initialize-DOKDsc` cmdlet (`dokd-init` for short). For a list of cmdlet options see [Initialize-DOKDsc](/docs/commands/Initialize-DOKDsc.md).

### EXAMPLE 1

Create a workspace.

```powershell
# Create a new workspace in the current working path
Initialize-DOKDsc;
```

```powershell
# Create a new workspace in the current working path
dokd-init;
```

### EXAMPLE 2

Restore an existing workspace from a git repository and restore dependencies. For a list of cmdlet options see [Restore-DOKDscModule](/docs/commands/Restore-DOKDscModule.md).

```powershell
# Use git to clone the repository
git clone <repository>;

cd .\<repository>

# Restore dependency modules to the workspace
dokd-restore;
```

## Create a configuration

After workspace is extablished the next step is to create a configuration.

### EXAMPLE 3

Create a new configuration named `Test`. A new configuration script will be created by default at `src\Configuration\Test.ps1`.

```powershell
# Create a configuration named Test
dokd-new 'Test';
```

### EXAMPLE 4

Create a new configuration named `Test` using an existing configuration script at `src\Configuration\Test.ps1`.

```powershell
dokd-new 'Test' '.\src\Configuration\Test.ps1'
```

## Build a configuration

### EXAMPLE 5

Builds all collections.

```powershell
dokd-build;
```

### EXAMPLE 6

Build a specific collection named `Test`.

```powershell
dokd-build 'Test';
```

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
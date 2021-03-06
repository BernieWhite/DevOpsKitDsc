# Feature details

The following sections describe DOKD features that enhance use of PowerShell Desired State Configuration (DSC).

## DevOps

DOKD helps to accelerate a DevOps workflow for DSC by providing pipeline automation for build and release processes.

- Build
- Release

## Collections

### Group configuration and nodes

DOKD uses collections, which is a pairing of a configuration script and one or more node configurations. Because collection are paired in advance, you can call them repatably by name.

## Build

### Module restore

Automatically restore module dependencies.

### Incremental build

When using incremental build, DSC configurations are only built when they have changed. This can add up to a substantial reduction in build time, when a large number of nodes exist in a collection.

The incremental build feature generates an signature based on:

- Configuration script
- Node data

By default signature data is stored in `.dok-obj` within a workspace. This path should be excluded from source control.

When using incremental build within a continuous integration/continuous deployment pipeline override the default signature path to a share or web location. The default signature data locations can be changed by using the [Set-DOKDscCollectionOption] cmdlet.

#### Using a Azure Blob Storage

A mentioned a web location can be used to store incremental signature information. Currently only Azure Blob Storage is supported.

Use the following steps to configure Azure Blob Storage as a location for incremental signatures:

1. Create or use an existing storage account
1. Create an empty blob container
1. Create a SAS signature with the `Read` and `Write` permissions
1. Use [Set-DOKDscCollectionOption] with the `-SignaturePath` and `-SignatureSasToken` parameters

### Documentation

Automatically generate per server documentation in markdown that can be shared across teams.

For details on the PSDocs syntax and output examples see [PSDocs][psdocs].

## Node configuration data

### Flat configuration data

PowerShell DSC includes a features called _configuration data_. Configuration data allows IT Pros to separate environmental or node settings from the configuration script, allowing administrator to avoid hard coding configuration settings that may differ between servers.

For example, consider the following configurations that might be maintained separately. Using _configuration data_, a single configuration script can used to manage each server independently without sacrificing code reuse.

| Server name | Environment | Role | Domain name | Web apps |
| ----------- | ----------- | ---- | ----------- | -------- |
| CPRDW01     | Production  | Web  | corp.contoso.com      | Intranet |
| CPRDW02     | Production  | Web  | corp.contoso.com      | TravelApp |
| CDEVW01     | Dev         | Web  | dev.contoso.com  | TravelApp |
| CTSTW01     | Test        | Web  | test.contoso.com | Intranet, TravelApp |

When using _configuration data_, DSC requires that the configuration of a node be included an `AllNodes` array.

```powershell
@{
    AllNodes = @(
        @{
            NodeName = 'CTSTW01'

            Environment = 'Test'

            # Add server roles here
            Role = @(
                'Web'
            )

            # Web applications to install when Web role is used
            WebApps = @(
                'TravelApp'
                'Intranet'
            )
        }
    )
}
```

When only a single node needs to be defined, adding the `AllNodes` array is unnecessary. In these cases, DOKD allows administrators to opt for a simple flat structure.

```powershell
@{
    NodeName = 'CTSTW01'

    Environment = 'Test'

    # Add server roles here
    Role = @(
        'Web'
    )

    # Web applications to install when Web role is used
    WebApps = @(
        'TravelApp'
        'Intranet'
    )
}
```

### Use JSON node configuration data

JavaScript-Object-Notation (JSON) is a data structure format that is widely used by modern web applications.

DOKD automatically detects and converts node configuration data stored in JSON files when building a collection configuration.

```json
{
    "AllNodes": [
        {
            "NodeName": "Server1",
            "Role": [
                "Web"
            ],
            "WebRoot": "E:\\www"
        },
        {
            "NodeName": "Server2",
            "Role": [
                "SQL"
            ]
        }
    ]
}
```

JSON formatted node data also supports DOKD flat configuration data.

```json
{
    "NodeName": "Server1",
    "Role": [
        "Web"
    ],
    "WebRoot": "E:\\www"
}
```

## Release

### Packaging modules for local pull server

When PowerShell modules containing DSC resources are deployed to local pull server configurations, each module must be zipped, named and a checksum generated before the pull server can correctly process them.

DOKD will download and package any dependency modules defined in the workspace.

To set this up in a workspace:

1. Set `Target = FileSystem` for the specific collection using the [Set-DOKDscCollectionOption]
2. Add one or more modules to the workspace with the [Add-DOKDscModule][dokd-add] command

```powershell
# Set a collection named SharePoint to package for local DSC server
Set-DOKDscCollectionOption -Name 'SharePoint' -Target FileSystem;

# Add v1.8.0.0 of the SharePointDsc module to the workspace
Add-DOKDscModule -ModuleName 'SharePointDsc' -ModuleVersion '1.8.0.0';
```

### Packaging modules for Azure Automation Service

When PowerShell modules containing DSC resources are deployed to Azure Automation Service, each module must be zipped and named before the service can correctly process them.

DOKD will download and package any dependency modules defined in the workspace.

To set this up in a workspace:

1. Set `Target = AzureAutomationService` for the specific collection using the [Set-DOKDscCollectionOption]
2. Add one or more modules to the workspace with the [Add-DOKDscModule][dokd-add] command

```powershell
# Set a collection named SharePoint to package for Azure Automation Service
Set-DOKDscCollectionOption -Name 'SharePoint' -Target AzureAutomationService;

# Add v1.8.0.0 of the SharePointDsc module to the workspace
Add-DOKDscModule -ModuleName 'SharePointDsc' -ModuleVersion '1.8.0.0';
```

### Packaging configuration for Azure Dsc Extension

When deploying DSC configurations using Azure Resource Manager (ARM) templates, ARM expects configurations to be presented as a zip file.

To set this up in a workspace:

1. Set `Target = AzureDscExtension` for the specific collection using the [Set-DOKDscCollectionOption]

```powershell
# Set a collection named SharePoint to package for Azure DSC extension
Set-DOKDscCollectionOption -Name 'SharePoint' -Target AzureDscExtension;
```

[psdocs]: https://github.com/BernieWhite/PSDocs
[dokd-add]: commands/en-US/Add-DOKDscModule.md
[Set-DOKDscCollectionOption]: commands/en-US/Set-DOKDscCollectionOption.md

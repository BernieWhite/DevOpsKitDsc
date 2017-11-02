# Feature details

The following sections decribe DOKD features that enhance use of PowerShell Desired State Configuration (DSC).

## Build

### Incremental build

When using incremental build, DSC configurations are only built when they have changed. This can add up to a substantial reducion in build time, when a large number of nodes exist in a collection.

The incremental build feature generates an integrity hash based on:

- Configuration script
- Node data

By default integrity data is stored in `.dok-obj` within a workspace. This path should be excluded from source control.

When using incremental build within a continious integration/continious deployment pipline override the default path to a share or web location.

### Documentation

Automatically generate per server documentation in markdown that can be shared across teams.

## Node configuration data

### Flat configuration data

PowerShell DSC includes a features called _configuration data_. Configuration data allows IT Pros to seperate environmental or node settings from the configuration script, allowing administrator to avoid hard coding configuration settings that may differ between servers.

For example, consider the following configurations that might be maintained seperately. Using _configuration data_, a single configuration script can used to manage each server independently without sacreficing code reuse.

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

## Packaging

### Packaging resource modules for local pull server

When PowerShell modules containing DSC resources are deployed to local pull server configurations, each module must be zipped, named and a checksum generated before the pull server can correctly process them.

DOKD will download and package any dependency modules defined in the workspace.

To set this up in a workspace:

1. Set Target = 0 for the specific collection using the [Set-DOKDscCollectionOption][Set-DOKDscCollectionOption]
2. Add one or more modules to the workspace with the [Add-DOKDscModule][dokd-add] command


```powershell
# Set a collection named SharePoint to package for local DSC server
Set-DOKDscCollectionOption -Name 'SharePoint' -Target 0;

# Add v1.8.0.0 of the SharePointDsc module to the workspace
Add-DOKDscMoulde -ModuleName 'SharePointDsc' -ModuleVersion '1.8.0.0';
```

### Packaging modules for Azure Automation Service

When PowerShell modules containing DSC resources are deployed to Azure Automation Service, each module must be zipped and named before the pull server can correctly process them.

DOKD will download and package any dependency modules defined in the workspace.

To set this up in a workspace:

1. Set Target = 1 for the specific collection using the [Set-DOKDscCollectionOption][Set-DOKDscCollectionOption]
2. Add one or more modules to the workspace with the [Add-DOKDscModule][dokd-add] command

```powershell
# Set a collection named SharePoint to package for Azure Automation Service
Set-DOKDscCollectionOption -Name 'SharePoint' -Target 1;

# Add v1.8.0.0 of the SharePointDsc module to the workspace
Add-DOKDscMoulde -ModuleName 'SharePointDsc' -ModuleVersion '1.8.0.0';
```

[dokd-add]: commands/en-US/Add-DOKDscModule.md
[Set-DOKDscCollectionOption]: commands/en-US/Set-DOKDscCollectionOption.md
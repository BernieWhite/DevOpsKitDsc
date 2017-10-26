# Feature details

The following sections decribe DOKD features that enhance use of PowerShell Desired State Configuration (DSC).

## Node configuration data

### Simple node configuration data

PowerShell DSC includes a features called _configuration data_. Configuration data allows IT Pros to seperate environmental or node settings from the configuration script, allowing administrator to avoid hard coding configuration settings that may differ between servers.

--DOKD gives administrators choice improves this further by 

For example:

| Server name | Environment | Role | Domain name | Web apps |
| ----------- | ----------- | ---- | ----------- | -------- |
| CPRDW01     | Production  | Web  | corp.contoso.com      | Intranet |
| CPRDW02     | Production  | Web  | corp.contoso.com      | TravelApp |
| CDEVW01     | Dev         | Web  | dev.contoso.com  | TravelApp |
| CTSTW01     | Test        | Web  | test.contoso.com | Intranet, TravelApp |

```powershell
@{
    AllNodes = @(
        @{
            NodeName = "CPRDW01"
        }
    )
}
```

```powershell
@{
    NodeName = "CPRDW01"
}
```

### Use JSON node configuration data

JavaScript-Object-Notation (JSON) is a data structure format that is widely used by modern web applications.

DOKD automatically detects and converts node configuration data stored in JSON files when building a collection configuration. JSON formatted node data also supports DOKD flot format.

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

When PowerShell modules containing DSC resources are deployed to local pull server configurations, each module must be ziped, named and a checksum generated before the pull server can correctly process them.

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

When PowerShell modules containing DSC resources are deployed to Azure Automation Service, each module must be ziped and named before the pull server can correctly process them.

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
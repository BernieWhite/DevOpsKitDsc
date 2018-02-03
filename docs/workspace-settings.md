# Workspace settings

_DevOps Kit for Dsc_ uses a `settings.json` file to store settings for the workspace. The `settings.json` file is stored within the `.dokd` under the root path of the workspace. This file can be modified directly or by using `Set`, `New` cmdlets in the _DevOpsKitDsc_ module.

## Structure

The structure of the workspace settings.json is as follows:

| Property | Requirement | Type | Description |
| -------- | ----------- | ---- | ----------- |
| `version` | Mandatory | string | The version of the workspace schema must be defined and set to `0.1.0`. |
| `description` | Optional | string | A description of the workspace. |
| `options` | Optional | object | Options that apply to the workspace. See [workspace options](#workspace-options). |
| `collections` | Optional | array of collections | One or more collections defined for the workspace. See [collections](#collections) for further detail. |
| `modules` | Optional | array of modules | One or more modules defined for the workspace. See [modules](#modules) for further detail. |

For example:

```json
{
    "version": "0.1.0",
    "description": "SharePoint farm solution.",
    "options": { },
    "collections": [ ],
    "modules": [ ]
}
```

### Workspace options

Configures options that affect the workspace. Workspace options can be set using the `Set-DOKDscWorkspaceOption` cmdlet.

| Property | Requirement | Type | Description |
| -------- | ----------- | ---- | ----------- |
| `modulePath` | Optional | string | The path to store dependency modules in. If this property is not defined, a default of `.\modules` will be used. |
| `nodePath` | Optional | string | The path that contains node data. If this property is not defined, a default of `.\nodes` will be used. |
| `outputPath` | Optional | string | A literal or relative path where output of build (.mof files) and publish processes will be stored. If this property is not defined, a default of `.\build` will be used. |

For example:

```json
{
    "modulePath": ".\\modules",
    "nodePath": ".\\nodes",
    "outputPath": ".\\out"
}
```

### Collections

Collection definitions for the workspace. New collections can be created using the `New-DOKDscCollection` cmdlet.

| Property | Requirement | Type | Description |
| -------- | ----------- | ---- | ----------- |
| `name` | Mandatory | string | The name of the collection. This property must be unique for each collection. |
| `path` | Mandatory | string | A literal or relative path to a configuration script file that contains the DSC configuration to use. |
| `configurationName` | Optional | string | The name of the configuration to build within the configuration script set by `path`. If this property is not provided the a configuration name with the same name of the file part of the path is used. |
| `options` | Optional | object | Options that apply to the collection. See collection options for further defail. |
| `data` | Optional | object | Data properties to merge into node data.  |
| `nodes` | Optional | array of strings | One or more path filters to include node data files with the .psd1 or .json suffix. |
| `docs` | Optional | object | Options for configuring documentation generation during build. |

For example:

```json
{
    "name": "SharePoint",
    "path": ".\\src\\Production\\SharePoint.ps1",
    "configurationName": "SharePoint",
    "options": { },
    "data": { },
    "nodes": [ ],
    "docs": { }
}
```

### Collection options

Configures options thaty affect a collection. Collection options can be use using the `Set-DOKDscCollectionOption` cmdlet.

| Property | Requirement | Type | Description |
| -------- | ----------- | ---- | ----------- |
| `target` | Optional | integer | The target for the configuration. 0 = File system, 1 = Azure Automation Service. |
| `replaceNodeData` | Optional | boolean | Determined if key/values defined in the data section replace node data, if include in both. The default is not to override data specified in the .psd1. |
| `buildMode` | Optional | integer | A mode for build operations. 1 = Incremental, 2 = Full. |
| `signaturePath` | Optional | string | The path to the location containing build signatures. |
| `signatureSasToken` | Optional | string | An optional shared access secret (SAS) token for authentication to the signature path. |

For example:

```json
{
    "target": 0,
    "replaceNodeData": false,
    "buildMode": 2,
    "signaturePath": "",
    "signatureSasToken": ""
}
```

### Modules

Provides a list of modules associated with the workspace.

| Property | Requirement | Type | Description |
| -------- | ----------- | ---- | ----------- |
| `name` | Mandatory | string | The name of the PowerShell module. |
| `version` | Mandatory | string | A specific version of the PowerShell module. |
| `repository` | Optional | string | The repository to download the module from. |

## JSON validation

A JSON schema exists as a file named `workspace-0.1.0.schema.json` in the root of the module.
---
external help file: DevOpsKitDsc-help.xml
Module Name: DevOpsKitDsc
online version: https://github.com/BernieWhite/DevOpsKitDsc/tree/master/docs/commands/en-US/Set-DOKDscCollectionOption.md
schema: 2.0.0
---

# Set-DOKDscCollectionOption

## SYNOPSIS

Set configuration options for the collection.

## SYNTAX

```text
Set-DOKDscCollectionOption [[-WorkspacePath] <String>] [-Name] <String> [[-Target] <ConfigurationOptionTarget>]
 [[-ReplaceNodeData] <Boolean>] [[-BuildMode] <CollectionBuildMode>] [[-SignaturePath] <String>]
 [[-SignatureSasToken] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Set configuration options for the collection.

## EXAMPLES

### Example 1

```powershell
PS C:\> Set-DOKDscCollectionOption -Name 'Test' -ReplaceNodeData $True;
```

Sets the replace node data option on the Test collection.

## PARAMETERS

### -BuildMode

Set the default build mode as either Full or Incremental. When this option is not set, incremental will be used by default.

```yaml
Type: CollectionBuildMode
Parameter Sets: (All)
Aliases:
Accepted values: Incremental, Full

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

The name of the collection to set options on.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReplaceNodeData

Controls how collection data variables are merged with node data. When set to $True, collection data variables replace node properties. When set to $False, collections data variables will add variables not defined within node data for a specific node.

When this option is not set, collection data will not replce node data. i.e. ReplaceNodeData = $False

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SignaturePath

Sets the location to store incremental build signatures. The location can be:

- A local or remote UNC directory path
- A HTTPS location such as Azure Blob Storage

When this options is not set the default location of .\dokd-obj will be used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SignatureSasToken

Set an option shared access signature (SAS) to be used when a HTTPS signature path is used. The SAS token will be appended to the URL. The SAS token should be prefixed with ?.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Target

Specified the target for publish operations. This option will affect how configuration and modules are packaged for publishing.

```yaml
Type: ConfigurationOptionTarget
Parameter Sets: (All)
Aliases:
Accepted values: FileSystem, AzureAutomationService, AzureDscExtension

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkspacePath

A workspace settings to use instead of reading from disk.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

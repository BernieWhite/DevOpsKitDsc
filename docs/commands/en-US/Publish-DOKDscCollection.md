---
external help file: DevOpsKitDsc-help.xml
Module Name: DevOpsKitDsc
online version: https://github.com/BernieWhite/DevOpsKitDsc/tree/master/docs/commands/en-US/Publish-DOKDscCollection.md
schema: 2.0.0
---

# Publish-DOKDscCollection

## SYNOPSIS

Publish the configuration of a collection.

## SYNTAX

```text
Publish-DOKDscCollection [[-Name] <String[]>] [[-WorkspacePath] <String>] [<CommonParameters>]
```

## DESCRIPTION

Publish the configuration of a collection.

## EXAMPLES

### Example 1

```powershell
PS C:\> Publish-DOKDscCollection;
```

Publish all collections in the workspace.

## PARAMETERS

### -Name

The name of the collection to publish.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkspacePath

The path to an existing workspace. If no value is specified the current working path is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Void

## NOTES

## RELATED LINKS

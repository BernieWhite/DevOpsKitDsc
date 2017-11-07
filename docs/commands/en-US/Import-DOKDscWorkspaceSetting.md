---
external help file: DevOpsKitDsc-help.xml
Module Name: DevOpsKitDsc
online version: https://github.com/BernieWhite/DevOpsKitDsc/tree/master/docs/commands/en-US/Import-DOKDscWorkspaceSetting.md
schema: 2.0.0
---

# Import-DOKDscWorkspaceSetting

## SYNOPSIS

Import workspace settings.

## SYNTAX

```powershell
Import-DOKDscWorkspaceSetting [[-WorkspacePath] <String>] [<CommonParameters>]
```

## DESCRIPTION

Import workspace settings.

## EXAMPLES

### Example 1

```powershell
PS C:\> Import-DOKDscWorkspaceSetting;
```

Import settings from a workspace in the current working path.

## PARAMETERS

### -WorkspacePath

The path to an existing workspace. If no value is specified the current working path is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path

Required: False
Position: 0
Default value: $PWD
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### DevOpsKitDsc.Workspace.WorkspaceSetting

## NOTES

## RELATED LINKS

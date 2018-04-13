---
external help file: DevOpsKitDsc-help.xml
Module Name: DevOpsKitDsc
online version: https://github.com/BernieWhite/DevOpsKitDsc/tree/master/docs/commands/en-US/Set-DOKDscWorkspaceOption.md
schema: 2.0.0
---

# Set-DOKDscWorkspaceOption

## SYNOPSIS

Set configuration options for the workspace.

## SYNTAX

```text
Set-DOKDscWorkspaceOption [[-WorkspacePath] <String>] [[-OutputPath] <String>] [[-NodePath] <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Set configuration options for the workspace.

## EXAMPLES

### Example 1

```powershell
PS C:\> Set-DOKDscWorkspaceOption -OutputPath '\\server1\dsc$';
```

Sets the output path for build and publish action to a remote UNC path.

## PARAMETERS

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

### -NodePath

Set the base path to look for node configuration data files. The path can be a specific local/remote location or relative to the workspace root. If this option is not set, the default .\nodes path will be used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath

Set the base path to output publish and build actions. The path can be a specific local/remote location or relative to the workspace root. If this option is not set, the default .\build path will be used.

Within the output path, separate folders will be created for each collection.

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

The path to an existing workspace. If no value is specified the current working path is used.

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

### System.Void

## NOTES

## RELATED LINKS

---
external help file: DevOpsKitDsc-help.xml
Module Name: DevOpsKitDsc
online version: https://github.com/BernieWhite/DevOpsKitDsc/tree/master/docs/commands/en-US/New-DOKDscCollection.md
schema: 2.0.0
---

# New-DOKDscCollection

## SYNOPSIS

Create a collection.

## SYNTAX

### Path (Default)

```powershell
New-DOKDscCollection [-WorkspacePath <String>] [-Name] <String> [[-Path] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Workspace

```powershell
New-DOKDscCollection -Workspace <WorkspaceSetting> [-Name] <String> [[-Path] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

Create a specific collection in the workspace.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-DOKDscCollection -Name 'Test';
```

Create collection called Test using the default configuration script template.

### Example 2

```powershell
PS C:\> New-DOKDscCollection -Name 'Test' -Path '.\src\Configuration\SharePoint.ps1';
```

Create a collection using an existing configuration script.

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

### -Name

The name of the collection to create.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

A path to an existing configuration script file.

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

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

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

### -Workspace

A workspace settings to use instead of reading from disk.

```yaml
Type: WorkspaceSetting
Parameter Sets: Workspace
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkspacePath

The path to an existing workspace. If no value is specified the current working path is used.

```yaml
Type: String
Parameter Sets: Path
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### DevOpsKitDsc.Workspace.Collection

## NOTES

## RELATED LINKS

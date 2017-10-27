---
external help file: DevOpsKitDsc-help.xml
Module Name: DevOpsKitDsc
online version: https://github.com/BernieWhite/DevOpsKitDsc/blob/master/docs/commands/en-US/Get-DOKDscCollection.md
schema: 2.0.0
---

# Get-DOKDscCollection

## SYNOPSIS

Get a collection.

## SYNTAX

### Path (Default)

```powershell
Get-DOKDscCollection [-WorkspacePath <String>] [-Name <String>] [<CommonParameters>]
```

### Setting

```powershell
Get-DOKDscCollection -Workspace <WorkspaceSetting> [-Name <String>] [<CommonParameters>]
```

## DESCRIPTION

Get a specific collection in the workspace.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-DOKDscCollection -Name 'Test';
```

Create collection called Test using the default configuration script template.

## PARAMETERS

### -Name

The name of the collection.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

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
Parameter Sets: Setting
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

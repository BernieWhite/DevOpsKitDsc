---
external help file: DevOpsKitDsc-help.xml
Module Name: DevOpsKitDsc
online version: https://github.com/BernieWhite/DevOpsKitDsc/tree/master/docs/commands/en-US/Get-DOKDscWorkspaceOption.md
schema: 2.0.0
---

# Get-DOKDscWorkspaceOption

## SYNOPSIS

Get the workspace options in the workspace.

## SYNTAX

```powershell
Get-DOKDscWorkspaceOption [[-WorkspacePath] <String>] [<CommonParameters>]
```

## DESCRIPTION

Get the workspace options in the workspace.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-DOKDscWorkspaceOption;
```

Get the workspace options in the workspace.

## PARAMETERS

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

### DevOpsKitDsc.Workspace.WorkspaceOption

## NOTES

## RELATED LINKS

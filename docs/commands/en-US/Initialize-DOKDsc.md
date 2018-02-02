---
external help file: DevOpsKitDsc-help.xml
Module Name: DevOpsKitDsc
online version: https://github.com/BernieWhite/DevOpsKitDsc/tree/master/docs/commands/en-US/Initialize-DOKDsc.md
schema: 2.0.0
---

# Initialize-DOKDsc

## SYNOPSIS

Create a workspace in the current working path or a specified location.

## SYNTAX

```text
Initialize-DOKDsc [[-WorkspacePath] <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION

Create a workspace in the current working path or a specified location.

## EXAMPLES

### Example 1

```powershell
PS C:\> Initialize-DOKDsc;
```

Create a workspace in the current working path.

### Example 2

```powershell
PS C:\> Initialize-DOKDsc -WorkspacePath '\\server1\DSC';
```

Create a workspace in the specified remote UNC path.

## PARAMETERS

### -Force

Force creation of the workspace path when the path does not already exist.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkspacePath

A path to create the workspace.  If no value is specified the workspace in created in the current working path.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path

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

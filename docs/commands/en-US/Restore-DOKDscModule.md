---
external help file: DevOpsKitDsc-help.xml
Module Name: DevOpsKitDsc
online version: https://github.com/BernieWhite/DevOpsKitDsc/tree/master/docs/commands/en-US/Restore-DOKDscModule.md
schema: 2.0.0
---

# Restore-DOKDscModule

## SYNOPSIS

Restore workspace module dependencies.

## SYNTAX

```text
Restore-DOKDscModule [[-WorkspacePath] <String>] [[-ModuleName] <String>] [[-ModuleVersion] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

Restore module dependencies for the specified workspace.

## EXAMPLES

### Example 1

```powershell
PS C:\> Restore-DOKDscModule;
```

Restore all module dependencies in the workspace.

### Example 2

```powershell
PS C:\> Restore-DOKDscModule -WorkspacePath '\\server1\DSC';
```

Restore all module dependencies for workspace stored in a remote UNC path.

### Example 3

```powershell
PS C:\> Restore-DOKDscModule -ModuleName 'SharePointDsc';
```

Restore a specific SharePointDsc module dependency.

## PARAMETERS

### -ModuleName

The name of the module to restore.

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

### -ModuleVersion

The version of the module to restore.

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

### System.Object

## NOTES

## RELATED LINKS

[Add-DOKDscModule](Add-DOKDscModule.md)

[Get-DOKDscModule](Get-DOKDscModule.md)

[Publish-DOKDscModule](Publish-DOKDscModule.md)
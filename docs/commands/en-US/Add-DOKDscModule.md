---
external help file: DevOpsKitDsc-help.xml
Module Name: DevOpsKitDsc
online version: https://github.com/BernieWhite/DevOpsKitDsc/blob/master/docs/commands/en-US/Add-DOKDscModule.md
schema: 2.0.0
---

# Add-DOKDscModule

## SYNOPSIS

Add a module dependency to the workspace.

## SYNTAX

### Module (Default)

```powershell
Add-DOKDscModule [-WorkspacePath <String>] -ModuleName <String> -ModuleVersion <String> [-Repository <String>]
 [-Type <String>] [<CommonParameters>]
```

### Path

```powershell
Add-DOKDscModule [-WorkspacePath <String>] -Path <String> [-Type <String>] [<CommonParameters>]
```

## DESCRIPTION

Add a module dependency to the workspace.

## EXAMPLES

### Example 1

```powershell
PS C:\> Add-DOKDscModule -ModuleName 'SharePointDsc' -ModuleVersion '1.8.0.0';
```

Add version 1.8.0.0 of the SharePointDsc module to the workspace.

## PARAMETERS

### -ModuleName

The name of the module.

```yaml
Type: String
Parameter Sets: Module
Aliases: Name

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleVersion

The version of the module.

```yaml
Type: String
Parameter Sets: Module
Aliases: Version

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

The path to the module.

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Repository

The name of the repository to use when restoring the module.

```yaml
Type: String
Parameter Sets: Module
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type

If the module is from this workspace or a repository.

When Workspace type is used no attept will be made to download the module from an external repository.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Workspace, Repository

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

### System.Object

## NOTES

## RELATED LINKS

[Get-DOKDscModule](Get-DOKDscModule.md)

[Restore-DOKDscModule](Restore-DOKDscModule.md)

[Publish-DOKDscModule](Publish-DOKDscModule.md)
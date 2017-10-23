---
external help file: DevOpsKitDsc-help.xml
online version: 
schema: 2.0.0
---

# Add-DOKDscModule

## SYNOPSIS

Add a module dependency to the workspace.

## SYNTAX

### Module (Default)

```powershell
Add-DOKDscModule [-WorkspacePath <String>] -ModuleName <String> -ModuleVersion <String> [-Repository <String>]
 [-Type <String>]
```

### Path

```powershell
Add-DOKDscModule [-WorkspacePath <String>] -Path <String> [-Type <String>]
```

## DESCRIPTION

{{Fill in the Description}}

## EXAMPLES

### Example 1

```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

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

{{Fill Path Description}}

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

{{Fill Repository Description}}

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

{{Fill Type Description}}

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

## INPUTS

### None


## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

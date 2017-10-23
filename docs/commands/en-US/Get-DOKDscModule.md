---
external help file: DevOpsKitDsc-help.xml
online version: 
schema: 2.0.0
---

# Get-DOKDscModule

## SYNOPSIS

Get a list of module dependencies in the workspace.

## SYNTAX

```powershell
Get-DOKDscModule [[-WorkspacePath] <String>] [[-ModuleName] <String>] [[-ModuleVersion] <String>]
```

## DESCRIPTION

Get a list of module dependencies in the workspace.

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
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleVersion

{{Fill ModuleVersion Description}}

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

## INPUTS

### None


## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

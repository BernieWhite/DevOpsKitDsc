---
external help file: DevOpsKitDsc-help.xml
online version: 
schema: 2.0.0
---

# Get-DOKDscCollection

## SYNOPSIS

Get a collection.

## SYNTAX

### Path (Default)

```powershell
Get-DOKDscCollection [-WorkspacePath <String>] [-Name <String>]
```

### Setting

```powershell
Get-DOKDscCollection -Workspace <WorkspaceSetting> [-Name <String>]
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

## INPUTS

### None


## OUTPUTS

### DevOpsKitDsc.Workspace.Collection


## NOTES

## RELATED LINKS

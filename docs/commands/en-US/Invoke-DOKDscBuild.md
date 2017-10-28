---
external help file: DevOpsKitDsc-help.xml
Module Name: DevOpsKitDsc
online version: https://github.com/BernieWhite/DevOpsKitDsc/tree/master/docs/commands/en-US/Invoke-DOKDscBuild.md
schema: 2.0.0
---

# Invoke-DOKDscBuild

## SYNOPSIS

Build collections in a workspace.

## SYNTAX

```powershell
Invoke-DOKDscBuild [[-Name] <String>] [[-InstanceName] <String[]>] [[-WorkspacePath] <String>]
 [[-ConfigurationData] <Object>] [[-Parameters] <IDictionary>] [<CommonParameters>]
```

## DESCRIPTION

Build collections in a workspace.

## EXAMPLES

### Example 1

```powershell
PS C:\> Invoke-DOKDscBuild;
```

{{ Add example description here }}

## PARAMETERS

### -ConfigurationData

{{Fill ConfigurationData Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InstanceName

{{Fill InstanceName Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The name of the collection to build. If a name is not specified all collections will be built.

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

### -Parameters
{{Fill Parameters Description}}

```yaml
Type: IDictionary
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkspacePath
The path to an existing workspace. If no value is specified the current working path is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path

Required: False
Position: 2
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


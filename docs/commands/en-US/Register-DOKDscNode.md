---
external help file: DevOpsKitDsc-help.xml
Module Name: DevOpsKitDsc
online version: https://github.com/BernieWhite/DevOpsKitDsc/tree/master/docs/commands/en-US/Register-DOKDscNode.md
schema: 2.0.0
---

# Register-DOKDscNode

## SYNOPSIS

Create a public/ private key pair for configuration encryption.

## SYNTAX

```text
Register-DOKDscNode [[-InstanceName] <String[]>] [[-WorkspacePath] <String>] [<CommonParameters>]
```

## DESCRIPTION

Create a public/private key pair for configuration encryption.

## EXAMPLES

### Example 1

```powershell
PS C:\> Register-DOKDscNode -InstanceName Server1;
```

Create and extract a public/ private key pair for the node `Server1`.

## PARAMETERS

### -InstanceName

The name of the node.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
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
Position: 1
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


[CmdletBinding()]
param (
    [Switch]$Scaffold = $False`
)

Import-Module '.\src\DevOpsKitDsc' -Force;


if ($Scaffold) {

    Update-MarkdownHelp -Path '.\docs\commands\en-US';
}
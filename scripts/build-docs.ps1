
[CmdletBinding()]
param (
    [Switch]$Scaffold = $False
)

if ($Scaffold) {
    Import-Module '.\src\DevOpsKitDsc' -Force;

    Update-MarkdownHelp -Path '.\docs\commands\en-US';

    return;
}

New-ExternalHelp -OutputPath '.\build\docs' -Path '.\docs\commands\en-US' -Force;

Copy-Item -Path '.\build\docs\DevOpsKitDsc-help.xml' -Destination '.\src\en-US';
Copy-Item -Path '.\build\docs\DevOpsKitDsc-help.xml' -Destination '.\src\en-AU';
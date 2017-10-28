
# Setup tests paths
$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$src = ($here -replace '\\tests\\', '\\src\\') -replace '\.Tests', '';
$temp = "$here\..\..\build";

Import-Module $src -Force;

$outputPath = "$temp\DevOpsKitDsc.Tests\Collection";

if ((Test-Path -Path $outputPath)) {
    Remove-Item -Path $outputPath -Recurse -Force;
}

New-Item -Path $outputPath -ItemType Directory -Force | Out-Null;
$outputPath = Resolve-Path -Path $outputPath;

Describe 'Workspace collection' {

    Context 'Create collection' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'CreateCollection';
        Initialize-DOKDsc -Path $contextPath -Force;

        It 'Executes successfully' {
            { New-DOKDscCollection -WorkspacePath $contextPath -Name 'NewCollection'; } | Should not throw;
        }

        It 'Configuration script is created' {
            Test-Path (Join-Path -Path $contextPath -ChildPath 'src\Configuration\NewCollection.ps1') | Should be $True;
        }

        It 'Configuration settings are minimal' {
            $workspaceSettingsContent = (Get-Content -Path "$contextPath\.dokd\settings.json" | ConvertFrom-Json).collections[0];
            $configItem = @($workspaceSettingsContent.PSObject.Properties);

            $configItem.Count | Should be 2;
        }

        # Get the collection
        $collection = Get-DOKDscCollection -WorkspacePath $contextPath -Name 'NewCollection';

        It 'Collection added to workspace' {
            $collection | Should not be $Null;
        }

        It 'Collection name is set' {
            $collection.Name | Should be 'NewCollection';
        }

        It 'Configuration script path is relative' {
            $collection.Path | Should be '.\src\Configuration\NewCollection.ps1';
        }
    }

    Context 'Publish a module for local pull server' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'PublishCollectionPullServer';
        Initialize-DOKDsc -Path $contextPath -Force;

        New-Item -Path "$contextPath\src\Test" -ItemType Directory -Force | Out-Null;

        Copy-Item -Path "$here\SampleConfiguration.ps1" -Destination "$contextPath\src\Test\SampleConfiguration.ps1";

        New-DOKDscCollection -WorkspacePath $contextPath -Name 'Test' -Path "$contextPath\src\Test\SampleConfiguration.ps1";

        Publish-DOKDscCollection -WorkspacePath $contextPath -Name 'Test';

        It 'Configuration is published to collection' {
            Test-Path -Path "$contextPath\build\Test\SampleConfiguration.ps1" | Should be $True;
        }
    }
}

# EOF

# Setup tests paths
$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$src = ($here -replace '\\tests\\', '\\src\\') -replace '\.Tests', '';
$temp = "$here\..\..\build";

Import-Module $src -Force;

$outputPath = "$temp\DevOpsKitDsc.Tests\Module";

if ((Test-Path -Path $outputPath)) {
    Remove-Item -Path $outputPath -Recurse -Force;
}

New-Item $outputPath -ItemType Directory -Force | Out-Null;

Describe 'Workspace module' {

    Context 'Add module to workspace without repository' {
        
        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'AddModule';
        Initialize-DOKDsc -Path $contextPath -Force;

        Add-DOKDscModule -WorkspacePath $contextPath -ModuleName 'Dummy' -ModuleVersion '0.2.0';
        
        $result = Import-DOKDscWorkspaceSetting -WorkspacePath $contextPath;

        It 'Workspace settings contains module' {
            ($result.Modules | Where-Object -FilterScript {
                $_.ModuleName -eq 'Dummy' -and $_.ModuleVersion -eq '0.2.0' -and [String]::IsNullOrEmpty($_.Repository)
            }) | Should not be $Null
        }
    }

    Context 'Add module to workspace with repository' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'AddModuleRepo';
        Initialize-DOKDsc -Path $contextPath -Force;

        Add-DOKDscModule -WorkspacePath $contextPath -ModuleName 'Dummy' -ModuleVersion '0.2.0' -Repository 'DummyRepo';
        
        $result = Import-DOKDscWorkspaceSetting -WorkspacePath $contextPath;

        It 'Workspace settings contains module' {
            ($result.Modules | Where-Object -FilterScript {
                $_.ModuleName -eq 'Dummy' -and $_.ModuleVersion -eq '0.2.0' -and $_.Repository -eq 'DummyRepo'
            }) | Should not be $Null
        }
    }

    Context 'Get a workspace module' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'GetModule';
        Initialize-DOKDsc -Path $contextPath -Force;

        Add-DOKDscModule -WorkspacePath $contextPath -ModuleName 'Dummy' -ModuleVersion '0.2.0';

        $result = Get-DOKDscModule -WorkspacePath $contextPath -ModuleName 'Dummy' -ModuleVersion '0.2.0';

        It 'Module can be read' {
            $result | Should not be $Null;
        }

        It 'Module name is expected' {
            $result.ModuleName | Should be 'Dummy';
        }

        It 'Module version is expected' {
            $result.ModuleVersion | Should be '0.2.0';
        }
    }

    Context 'Publish a module that does not exist' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'PublishModuleDoesNotExist';
        Initialize-DOKDsc -Path $contextPath -Force;

        It 'Fails to publish module' {
            { Publish-DOKDscModule -WorkspacePath $contextPath -ModuleName 'Test' -ModuleVersion '1.0.0.0' } | Should throw 'Module does not exist.';
        }
    }

    Context 'Publish a module for local pull server' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'PublishModulePullServer';
        Initialize-DOKDsc -Path $contextPath -Force;

        New-Item -Path "$contextPath\src\Test" -ItemType Directory -Force | Out-Null;
        New-ModuleManifest -Path "$contextPath\src\Test\Test.psd1" -ModuleVersion '1.0.0.0' -Guid '7c692c7f-9f3f-4915-95c5-f0b8118ee763';

        Add-DOKDscModule -WorkspacePath $contextPath -Type 'Workspace' -Path '.\src\Test';

        Restore-DOKDscModule -WorkspacePath $contextPath -ModuleName 'Test' -ModuleVersion '1.0.0.0';

        New-DOKDscCollection -WorkspacePath $contextPath -Name 'Test';

        # Restore-DOKWorkspace -WorkspacePath $contextPath;
        Publish-DOKDscModule -Name 'Test' -WorkspacePath $contextPath -ModuleName 'Test' -ModuleVersion '1.0.0.0';

        It 'Publishes the module' {
            Test-Path -Path "$contextPath\build\Test_1.0.0.0.zip" | Should be $True;
        }
    }

    Context 'Publish a module for Azure Automation Service' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'PublishModuleAAS';
        Initialize-DOKDsc -Path $contextPath -Force;

        New-Item -Path "$contextPath\src\Test" -ItemType Directory -Force | Out-Null;
        New-ModuleManifest -Path "$contextPath\src\Test\Test.psd1" -ModuleVersion '1.0.0.0' -Guid '7c692c7f-9f3f-4915-95c5-f0b8118ee763';

        Add-DOKDscModule -WorkspacePath $contextPath -Type 'Workspace' -Path '.\src\Test';

        Restore-DOKDscModule -WorkspacePath $contextPath -ModuleName 'Test' -ModuleVersion '1.0.0.0';

        New-DOKDscCollection -WorkspacePath $contextPath -Name 'Test' -Options @{ Target = [DevOpsKitDsc.Workspace.ConfigurationOptionTarget]::AzureAutomationService; };

        # Restore-DOKWorkspace -WorkspacePath $contextPath;
        Publish-DOKDscModule -Name 'Test' -WorkspacePath $contextPath -ModuleName 'Test' -ModuleVersion '1.0.0.0';

        It 'Publishes the module' {
            Test-Path -Path "$contextPath\build\Test.zip" | Should be $True;
        }
    }
}

# EOF
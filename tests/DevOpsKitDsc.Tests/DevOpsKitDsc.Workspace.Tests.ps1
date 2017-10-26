
# Setup tests paths
$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$src = ($here -replace '\\tests\\', '\\src\\') -replace '\.Tests', '';
$temp = "$here\..\..\build";

Import-Module $src -Force;

$outputPath = "$temp\DevOpsKitDsc.Tests\Workspace";

if ((Test-Path -Path $outputPath)) {
    Remove-Item -Path $outputPath -Recurse -Force;
}

New-Item $outputPath -ItemType Directory -Force | Out-Null;

Describe 'Workspace module' {
    Context 'Initialize workspace' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'Initialize';
        Initialize-DOKDsc -Path $contextPath -Force;

        $result = Import-DOKDscWorkspaceSetting -WorkspacePath $contextPath;

        It 'Workspace is created successfully' {
            Test-Path -Path "$contextPath\.dokd\settings.json" | Should be $True;
        }
        
        It 'Workspace settings can be read successfully' {
            $result | Should not be $null;
        }

        It 'Workspace default output path is correct' {
            $result.Options.OutputPath | Should be '.\build';
        }

        It 'Workspace default node path is correct' {
            $result.Options.NodePath | Should be '.\nodes';
        }
    }

    Context 'Initialize workspace with invalid path' {
    
        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'InitializeInvalid';

        It 'Initialize throws an exception' {
            { Initialize-DOKDsc -Path $contextPath } | Should throw "The workspace path does not exist.";
        }

        It 'Workspace does not exist' {
            Test-Path -Path "$contextPath\workspace.json" | Should be $False;
        }
        
        It 'Workspace settings can not be read' {
            { Import-DOKDscWorkspaceSetting -WorkspacePath $contextPath } | Should throw "The workspace path does not exist.";
        }
    }

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

    Context 'Restore workspace' {

        Mock -CommandName 'ReadWorkspaceSetting' -ModuleName 'DevOpsKitDsc' -Verifiable -MockWith {
            $setting = [DevOpsKitDsc.Workspace.WorkspaceHelper]::LoadDefault();

            $setting.Modules.Add((New-Object -TypeName DevOpsKitDsc.Workspace.Module -Property @{ ModuleName = 'Test'; ModuleVersion = '0.0.0'; }));

            return $setting;
        }

        Mock -CommandName 'SaveModule' -ModuleName 'DevOpsKitDsc' -Verifiable -MockWith {
            param (
                [Parameter(Mandatory = $True)]
                [DevOpsKitDsc.Workspace.Module]$Module,
        
                [Parameter(Mandatory = $True)]
                [String]$OutputPath
            )
        }

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'Restore';
        Initialize-DOKDsc -Path $contextPath -Force;

        Restore-DOKDscModule -WorkspacePath $contextPath;

        It 'Workspace settings read' {
            Assert-MockCalled -CommandName 'ReadWorkspaceSetting' -ModuleName 'DevOpsKitDsc' -Times 1;
        }

        It 'Module restored' {
            Assert-MockCalled -CommandName 'SaveModule' -ModuleName 'DevOpsKitDsc' -Times 1;
        }
    }

    Context 'Set workspace options' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'SetWorkspaceOptions';
        Initialize-DOKDsc -Path $contextPath -Force;

        # Set the workspace options
        Set-DOKDscWorkspaceOption -WorkspacePath $contextPath -OutputPath '.\dummy\output' -NodePath '.\dummy\nodes';

        # Get the workspace options
        $result = Get-DOKDscWorkspaceOption -WorkspacePath $contextPath;

        It 'Output path is set' {
            $result.OutputPath | Should be '.\dummy\output';
        }

        It 'NodePath path is set' {
            $result.NodePath | Should be '.\dummy\nodes';
        }
    }

    Context 'Workspace options are not set with whatif' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'SetWorkspaceOptionsWhatIf';
        Initialize-DOKDsc -Path $contextPath -Force;

        Mock -CommandName 'WriteWorkspaceSetting' -ModuleName 'DevOpsKitDsc' -Verifiable -MockWith {

        }

        # Set the workspace options
        Set-DOKDscWorkspaceOption -WorkspacePath $contextPath -OutputPath '.\dummy\output' -NodePath '.\dummy\nodes' -WhatIf;

        It 'Write workspace options is not called' {
            Assert-MockCalled -CommandName 'WriteWorkspaceSetting' -ModuleName 'DevOpsKitDsc' -Times 0;
        }
    }

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
}

# EOF
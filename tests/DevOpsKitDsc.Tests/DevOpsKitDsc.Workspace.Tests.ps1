
Set-StrictMode -Version latest;

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

Describe 'Workspace' {
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
}

# EOF
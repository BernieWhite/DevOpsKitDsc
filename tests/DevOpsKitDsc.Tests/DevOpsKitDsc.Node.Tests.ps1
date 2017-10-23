
# Setup tests paths
$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$src = ($here -replace '\\tests\\', '\\src\\') -replace '\.Tests', '';
$temp = "$here\..\..\build";

Import-Module $src -Force;

$outputPath = "$temp\DevOpsKitDsc.Tests\Node";

if ((Test-Path -Path $outputPath)) {
    Remove-Item -Path $outputPath -Recurse -Force;
}

New-Item $outputPath -ItemType Directory -Force | Out-Null;

$Global:TestVars = @{ Here = $here; };

Describe 'Node module' {
    Context 'Import node data' {

        Mock -CommandName 'ImportNodeData' -ModuleName 'DevOpsKitDsc' -Verifiable -MockWith {
            param (
                [Parameter(Mandatory = $True)]
                [String[]]$NodePath,
        
                [Parameter(Mandatory = $False)]
                [AllowEmptyCollection()]
                [AllowNull()]
                [String[]]$InstanceName = $Null
            )

            process {
                return @($InstanceName | ForEach-Object -Process {
                    New-Object -TypeName PSObject -Property @{
                    InstanceName = $_;
                    ConfigurationData = @{
                        NodeName = $_;
                    }
                }});
            }
        }

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'ImportNodeConfig';
        Initialize-DOKDsc -Path $contextPath -Force;

        $result = Import-DOKDscNodeConfiguration -InstanceName 'ImportNodeConfig' -WorkspacePath $contextPath -Verbose:$VerbosePreference;

        It 'Node data imported successfully' {
            $result | Should not be $Null;
        }

        It 'Node data is read from file' {
            Assert-MockCalled -CommandName 'ImportNodeData' -ModuleName 'DevOpsKitDsc' -Times 1;
        }

        It 'Node name is expected' {
            $result.NodeName | Should be 'ImportNodeConfig';
        }
    }

    Context 'Read single node PSD1' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'ReadPSD1SingleNode';
        Initialize-DOKDsc -Path $contextPath -Force;

        $nodeDataPath = Join-Path -Path $contextPath -ChildPath 'nodes';
        New-Item -Path $nodeDataPath -Force -ItemType Directory | Out-Null;

        Set-Content -Path (Join-Path -Path $nodeDataPath -ChildPath 'node1.psd1') -Value '@{ NodeName = "Node1"; Role = "Test"; }';

        $result = Import-DOKDscNodeConfiguration -InstanceName 'Node1' -WorkspacePath $contextPath -Verbose:$VerbosePreference;
        
        It 'Node data imported successfully' {
            $result | Should not be $Null;
        }
        
        It 'Node name is expected' {
            $result.NodeName | Should be 'Node1';
        }
    }

    Context 'Read multi-node PSD1' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'ReadPSD1MultiNode';
        Initialize-DOKDsc -Path $contextPath -Force;

        $nodeDataPath = Join-Path -Path $contextPath -ChildPath 'nodes';
        New-Item -Path $nodeDataPath -Force -ItemType Directory | Out-Null;

        Set-Content -Path (Join-Path -Path $nodeDataPath -ChildPath 'node1.psd1') -Value '@{ AllNodes = @( @{ NodeName = "Node1"; Role = "Database"; }, @{ NodeName = "Node2"; Role = "Web"; } ) }';

        $result = Import-DOKDscNodeConfiguration -InstanceName 'Node1' -WorkspacePath $contextPath -Verbose:$VerbosePreference;
        
        It 'Node data imported successfully' {
            $result | Should not be $Null;
        }
        
        It 'Node name is expected' {
            ($result.AllNodes | Where-Object -FilterScript { $_.NodeName -eq 'Node1' }) | Should not be $Null;
        }

        It 'Node name is expected' {
            ($result.AllNodes | Where-Object -FilterScript { $_.NodeName -eq 'Node2' }) | Should not be $Null;
        }
    }

    Context 'Read single node JSON' {
        
        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'ReadJSONSingleNode';
        Initialize-DOKDsc -Path $contextPath -Force;

        $nodeDataPath = Join-Path -Path $contextPath -ChildPath 'nodes';
        New-Item -Path $nodeDataPath -Force -ItemType Directory | Out-Null;

        Set-Content -Path (Join-Path -Path $nodeDataPath -ChildPath 'node1.json') -Value (@{ NodeName = "Node1"; Role = "Test"; } | ConvertTo-Json -Depth 5);

        $result = Import-DOKDscNodeConfiguration -InstanceName 'Node1' -WorkspacePath $contextPath -Verbose:$VerbosePreference;
        
        It 'Node data imported successfully' {
            $result | Should not be $Null;
        }
        
        It 'Node name is expected' {
            $result.NodeName | Should be 'Node1';
        }
    }

    Context 'Read multi-node JSON' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'ReadJSONMultiNode';
        Initialize-DOKDsc -Path $contextPath -Force;

        $nodeDataPath = Join-Path -Path $contextPath -ChildPath 'nodes';
        New-Item -Path $nodeDataPath -Force -ItemType Directory | Out-Null;

        Set-Content -Path (Join-Path -Path $nodeDataPath -ChildPath 'node1.json') -Value (@{ AllNodes = @( @{ NodeName = "Node1"; Role = "Database"; }, @{ NodeName = "Node2"; Role = "Web"; } ) } | ConvertTo-Json -Depth 5);

        $result = Import-DOKDscNodeConfiguration -InstanceName 'Node1' -WorkspacePath $contextPath -Verbose:$VerbosePreference;
        
        It 'Node data imported successfully' {
            $result | Should not be $Null;
        }
        
        It 'Node name is expected' {
            ($result.AllNodes | Where-Object -FilterScript { $_.NodeName -eq 'Node1' }) | Should not be $Null;
        }

        It 'Node name is expected' {
            ($result.AllNodes | Where-Object -FilterScript { $_.NodeName -eq 'Node2' }) | Should not be $Null;
        }
    }

    Context 'Import without workspace' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'ImportWithoutWorkspace';

        It 'Import should error' {
            { Import-DOKDscNodeConfiguration -InstanceName 'ImportWithoutWorkspace' -WorkspacePath $contextPath } | Should throw 'The workspace path does not exist.';
        }
    }

    Context 'Register without node data' {

        Mock -CommandName 'RegisterNode' -ModuleName 'DevOpsKitDsc' -Verifiable -MockWith {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $True)]
                [PSObject]$Node,
        
                [Parameter(Mandatory = $True)]
                [String]$OutputPath
            )

            process { }
        }

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'RegisterWithoutNodeData';
        Initialize-DOKDsc -Path $contextPath -Force;

        It 'Node data is not found' {
            { Register-DOKDscNode -WorkspacePath $contextPath -InstanceName 'Instance1' } | Should throw 'Cannot find node data.';
        }

        It 'Register node is not called' {
            Assert-MockCalled -CommandName 'RegisterNode' -ModuleName 'DevOpsKitDsc' -Times 0;
        }
    }

    Context 'Register with node data' {

        Mock -CommandName 'ImportNodeData' -ModuleName 'DevOpsKitDsc' -Verifiable -MockWith {
            param (
                [Parameter(Mandatory = $True)]
                [String[]]$NodePath,
        
                [Parameter(Mandatory = $False)]
                [AllowEmptyCollection()]
                [AllowNull()]
                [String[]]$InstanceName = $Null
            )

            process {
                return @($InstanceName | ForEach-Object -Process {
                    New-Object -TypeName PSObject -Property @{
                    InstanceName = $_;
                    ConfigurationData = @{
                        NodeName = $_;
                    }
                }});
            }
        }

        Mock -CommandName 'RegisterNode' -ModuleName 'DevOpsKitDsc' -Verifiable -MockWith {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $True)]
                [PSObject]$Node,
        
                [Parameter(Mandatory = $True)]
                [String]$OutputPath
            )

            process { }
        }

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'RegisterNode';
        Initialize-DOKDsc -Path $contextPath -Force;

        # Register the node
        Register-DOKDscNode -WorkspacePath $contextPath -InstanceName 'Instance1';

        It 'Register node is called' {
            Assert-MockCalled -CommandName 'RegisterNode' -ModuleName 'DevOpsKitDsc' -Times 1;
        }
    }

    Context 'Generate node configuration' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'CompileConfiguration';
        Initialize-DOKDsc -Path $contextPath -Force;

        $Global:TestVars['CompileConfiguration::ContextPath'] = $contextPath;

        Mock -CommandName 'Import-DOKDscWorkspaceSetting' -ModuleName 'DevOpsKitDsc' -Verifiable -MockWith {
            $default = [DevOpsKitDsc.Workspace.WorkspaceHelper]::LoadDefault();

            $configuration = New-Object -TypeName DevOpsKitDsc.Workspace.Collection;
            $configuration.Path = "$($Global:TestVars['Here'])\SampleConfiguration.ps1";
            $configuration.Nodes = [String[]]@('Test');

            $default.Collections.Add($configuration);

            return $default;
        }

        Mock -CommandName 'ImportNodeData' -ModuleName 'DevOpsKitDsc' -Verifiable -MockWith {
            $result = New-Object -TypeName PSObject -Property @{
                InstanceName = 'Test';
                BaseDirectory = "$($Global:TestVars['Here'])\nodes\Test";
                ConfigurationData = @{
                    AllNodes = @(
                        @{
                            NodeName = 'Test'
                        }
                    )
                }
            }

            return $result;
        }

        $nodeMofPath = Join-Path -Path $contextPath -ChildPath 'build\Test.mof';
        Invoke-DOKDscBuild -WorkspacePath $contextPath;

        It 'Node configuration is generated successfully' {
            Test-Path -Path $nodeMofPath -PathType Leaf | Should be $True;
        }

        It 'Configuration contain expected content' {
            Get-Content -Path $nodeMofPath -Raw | Should match '(ResourceID \= \"\[File\]FileResorce\";)(.|\r\n){1,}(ConfigurationName \= \"SampleConfiguration\";)';
        }

        It 'Node configuration checksum is created' {
            Test-Path -Path "$nodeMofPath.checksum" -PathType Leaf | Should be $True;
        }

        It 'Checksum matches expected value' {
            Get-Content -Path "$nodeMofPath.checksum" -Raw | Should be (Get-FileHash -Path $nodeMofPath -Algorithm SHA256).Hash;
        }
    }
}

# EOF
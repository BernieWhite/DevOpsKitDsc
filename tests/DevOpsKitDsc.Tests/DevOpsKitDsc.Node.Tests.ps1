
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
                [String]$WorkspacePath,

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

        Set-Content -Path (Join-Path -Path $nodeDataPath -ChildPath 'node1.psd1') -Value '@{ NodeName = "Node1"; Role = "Web"; }';

        $result = Import-DOKDscNodeConfiguration -InstanceName 'Node1' -WorkspacePath $contextPath -Verbose:$VerbosePreference;
        
        It 'Node data imported successfully' {
            $result | Should not be $Null;
        }
        
        It 'Node name is expected' {
            $result.NodeName | Should be 'Node1';
        }

        It 'Node data is expected' {
            $result.Role | Should be 'Web';
        }
    }

    Context 'Read multi-node PSD1' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'ReadPSD1MultiNode';
        Initialize-DOKDsc -Path $contextPath -Force;

        $nodeDataPath = Join-Path -Path $contextPath -ChildPath 'nodes';
        New-Item -Path $nodeDataPath -Force -ItemType Directory | Out-Null;

        Set-Content -Path (Join-Path -Path $nodeDataPath -ChildPath 'node1.psd1') -Value '@{ AllNodes = @( @{ NodeName = "Node1"; Role = @("Database"); }, @{ NodeName = "Node2"; Role = @("Web"); } ) }';

        $result = Import-DOKDscNodeConfiguration -InstanceName 'Node1' -WorkspacePath $contextPath -Verbose:$VerbosePreference;
        
        It 'Node data imported successfully' {
            $result | Should not be $Null;
        }
        
        It 'Node name is expected' {
            ($result.AllNodes | Where-Object -FilterScript { $_.NodeName -eq 'Node1' }) | Should not be $Null;
        }

        It 'Node role is expected' {
            ($result.AllNodes | Where-Object -FilterScript { $_.NodeName -eq 'Node1' }).Role | Should be 'Database';
        }

        It 'Node name is expected' {
            ($result.AllNodes | Where-Object -FilterScript { $_.NodeName -eq 'Node2' }) | Should not be $Null;
        }

        It 'Node role is expected' {
            ($result.AllNodes | Where-Object -FilterScript { $_.NodeName -eq 'Node2' }).Role | Should be 'Web';
        }
    }

    Context 'Read single node JSON' {
        
        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'ReadJSONSingleNode';
        Initialize-DOKDsc -Path $contextPath -Force;

        $nodeDataPath = Join-Path -Path $contextPath -ChildPath 'nodes';
        New-Item -Path $nodeDataPath -Force -ItemType Directory | Out-Null;

        $nodeData = @{
            NodeName = "Node1";
            Role = "Web";
        }

        Set-Content -Path (Join-Path -Path $nodeDataPath -ChildPath 'node1.json') -Value (
            $nodeData | ConvertTo-Json -Depth 5
        );

        $result = Import-DOKDscNodeConfiguration -InstanceName 'Node1' -WorkspacePath $contextPath -Verbose:$VerbosePreference;
        
        It 'Node data imported successfully' {
            $result | Should not be $Null;
        }
        
        It 'Node was imported' {
            $result.NodeName | Should be 'Node1';
        }

        It 'Node role data was imported' {
            $result.Role | Should be 'Web';
        }
    }

    Context 'Read multi-node JSON' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'ReadJSONMultiNode';
        Initialize-DOKDsc -Path $contextPath -Force;

        $nodeDataPath = Join-Path -Path $contextPath -ChildPath 'nodes';
        New-Item -Path $nodeDataPath -Force -ItemType Directory | Out-Null;

        $nodeData = @{
            AllNodes = @(
                @{
                    NodeName = "Node1";
                    Role = @("Database");
                },
                @{
                    NodeName = "Node2";
                    Role = @("Web");
                }
            )
        }

        Set-Content -Path (Join-Path -Path $nodeDataPath -ChildPath 'node1.json') -Value (
            $nodeData | ConvertTo-Json -Depth 5
        );

        $result = Import-DOKDscNodeConfiguration -InstanceName 'Node1' -WorkspacePath $contextPath -Verbose:$VerbosePreference;
        
        It 'Node data imported successfully' {
            $result | Should not be $Null;
        }
        
        It 'Node (1) was imported' {
            ($result.AllNodes | Where-Object -FilterScript { $_.NodeName -eq 'Node1' }).NodeName | Should be 'Node1';
        }

        It 'Node (1) role was imported' {
            ($result.AllNodes | Where-Object -FilterScript { $_.NodeName -eq 'Node1' }).Role | Should be 'Database';
        }

        It 'Node (2) was imported' {
            ($result.AllNodes | Where-Object -FilterScript { $_.NodeName -eq 'Node2' }).NodeName | Should be 'Node2';
        }

        It 'Node (2) role was imported' {
            ($result.AllNodes | Where-Object -FilterScript { $_.NodeName -eq 'Node2' }).Role | Should be 'Web';
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
                [String]$WorkspacePath,

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

        Mock -CommandName 'GetNodeSessionConfiguration' -ModuleName 'DevOpsKitDsc' -Verifiable -MockWith {
            [CmdletBinding()]
            [OutputType([Hashtable])]
            param (
                [Parameter(Mandatory = $True)]
                [String]$InstanceName
            )

            process {
                return @{ UseSession = $False; CreateCertificate = $True; };
            }
        }

        Mock -CommandName 'EnrollCertificate' -ModuleName 'DevOpsKitDsc' -Verifiable -MockWith {

        }

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'RegisterNode';
        Initialize-DOKDsc -Path $contextPath -Force;

        # Register the node
        Register-DOKDscNode -WorkspacePath $contextPath -InstanceName 'Instance1';

        It 'Register node is called' {
            Assert-MockCalled -CommandName 'GetNodeSessionConfiguration' -ModuleName 'DevOpsKitDsc' -Times 1;
        }
    }

    Context 'Build node' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'BuildNode';
        Initialize-DOKDsc -Path $contextPath -Force;

        $srcPath = Join-Path -Path $contextPath -ChildPath 'src\Test';
        New-Item -Path $srcPath -ItemType Directory -Force | Out-Null;

        $collectionParams = @{
            WorkspacePath = $contextPath
            Name = 'Test'
            Nodes = @('Test')
            Path = '.\src\Test\SampleConfiguration.ps1'
        }

        Copy-Item -Path "$here\SampleConfiguration.ps1" -Destination "$srcPath\" -Force;

        New-DOKDscCollection @collectionParams;

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

        # Build all collection in the default output path
        Invoke-DOKDscBuild -WorkspacePath $contextPath;
        $nodeMofPath = Join-Path -Path $contextPath -ChildPath 'build\Test\Test.mof';

        It 'Configuration is built' {
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
        
        # Build all collections with an alternative output path set
        Set-DOKDscWorkspaceOption -WorkspacePath $contextPath -OutputPath '.\build2';
        Invoke-DOKDscBuild -WorkspacePath $contextPath;
        $nodeMofPath2 = Join-Path -Path $contextPath -ChildPath 'build2\Test\Test.mof';

        # Check that the same configuration was not rebuild
        It 'Incremental configuration not built' {
            Test-Path -Path $nodeMofPath2 -PathType Leaf | Should be $False;
        }

        # Force build all collections with an alternative output path set
        Set-DOKDscWorkspaceOption -WorkspacePath $contextPath -OutputPath '.\build3';
        Invoke-DOKDscBuild -WorkspacePath $contextPath -Force;
        $nodeMofPath3 = Join-Path -Path $contextPath -ChildPath 'build3\Test\Test.mof';
        
        # Check that configuration is built again because force was used
        It 'Forced configuration is built' {
            Test-Path -Path $nodeMofPath3 -PathType Leaf | Should be $True;
        }
    }

    Context 'Build incremental' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'BuildNodeIncremental';
        Initialize-DOKDsc -Path $contextPath -Force;

        $srcPath = Join-Path -Path $contextPath -ChildPath 'src\Test';
        New-Item -Path $srcPath -ItemType Directory -Force | Out-Null;
        $incPath = Join-Path -Path $contextPath -ChildPath 'inc';
        New-Item -Path $incPath -ItemType Directory -Force | Out-Null;

        $collectionParams = @{
            WorkspacePath = $contextPath
            Name = 'Test'
            Nodes = @('Test')
            Path = '.\src\Test\SampleConfiguration.ps1'
            Options = @{
                SignaturePath = '.\inc'
            }
        }

        Copy-Item -Path "$here\SampleConfiguration.ps1" -Destination "$srcPath\" -Force;

        New-DOKDscCollection @collectionParams;

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

        # Build all collection in the default output path
        Invoke-DOKDscBuild -WorkspacePath $contextPath;
        $nodeMofPath = Join-Path -Path $contextPath -ChildPath 'build\Test\Test.mof';
        $buildSignaturePath = Join-Path -Path $contextPath -ChildPath 'inc\Test.Test.json';

        It 'Configuration is built' {
            Test-Path -Path $nodeMofPath -PathType Leaf | Should be $True;
        }

        It 'Build signature was created' {
            Test-Path -Path $buildSignaturePath -PathType Leaf | Should be $True;
        }
        
        # Build all collections with an alternative output path set
        Set-DOKDscWorkspaceOption -WorkspacePath $contextPath -OutputPath '.\build2';
        Invoke-DOKDscBuild -WorkspacePath $contextPath;
        $nodeMofPath2 = Join-Path -Path $contextPath -ChildPath 'build2\Test\Test.mof';

        # Check that the same configuration was not rebuild
        It 'Incremental configuration not built' {
            Test-Path -Path $nodeMofPath2 -PathType Leaf | Should be $False;
        }
    }

    Context 'Build incremental with HTTPS' {

        # Init the workspace
        $contextPath = Join-Path -Path $outputPath -ChildPath 'BuildNodeIncrementalHTTPS';
        Initialize-DOKDsc -Path $contextPath -Force;

        $srcPath = Join-Path -Path $contextPath -ChildPath 'src\Test';
        New-Item -Path $srcPath -ItemType Directory -Force | Out-Null;
        $incPath = Join-Path -Path $contextPath -ChildPath 'inc';
        New-Item -Path $incPath -ItemType Directory -Force | Out-Null;

        $collectionParams = @{
            WorkspacePath = $contextPath
            Name = 'Test'
            Nodes = @('Test')
            Path = '.\src\Test\SampleConfiguration.ps1'
            Options = @{
                SignaturePath = 'https://localhost/'
                SignatureSasToken = '?token=test'
            }
        }

        Copy-Item -Path "$here\SampleConfiguration.ps1" -Destination "$srcPath\" -Force;

        New-DOKDscCollection @collectionParams;

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

        Mock -CommandName 'ReadBuildSignatureWeb' -ModuleName 'DevOpsKitDsc' -Verifiable -MockWith {

        }

        Mock -CommandName 'WriteBuildSignatureWeb' -ModuleName 'DevOpsKitDsc' -Verifiable -MockWith {
            
        }

        # Build all collection in the default output path
        Invoke-DOKDscBuild -WorkspacePath $contextPath;

        It 'Read is called' {
            Assert-MockCalled -CommandName 'ReadBuildSignatureWeb' -ModuleName 'DevOpsKitDsc' -Times 1;
        }

        It 'Write is called' {
            Assert-MockCalled -CommandName 'WriteBuildSignatureWeb' -ModuleName 'DevOpsKitDsc' -Times 1;
        }
    }
}

# EOF
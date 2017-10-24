#
# DevOps Kit for Desired State Configuration
#

# Import helper classes
if (!$PSVersionTable.PSEdition -or $PSVersionTable.PSEdition -eq "Desktop") {
    Import-Module -Name "$PSScriptRoot/bin/Debug/net451/publish/DevOpsKitDsc.dll" | Out-Null
}
else {
    Import-Module -Name "$PSScriptRoot/bin/Debug/netstandard1.6/publish/DevOpsKitDsc.dll" | Out-Null
}

#
# Localization
#

$LocalizedData = data {

}

Import-LocalizedData -BindingVariable LocalizedData -FileName 'DevOpsKitDsc.Resources.psd1' -ErrorAction SilentlyContinue;

#
# Public functions
#

#region Public functions

# Bootstrap a DSC node with an encryption certificate and modules
function Register-DOKDscNode {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False)]
        [String[]]$InstanceName,

        [Parameter(Mandatory = $False)]
        [Alias('Path')]
        [String]$WorkspacePath = $PWD
    )

    begin {
        Write-Verbose -Message "[DOKDsc] BEGIN::";
    }

    process {

        if (!(Test-Path -Path $WorkspacePath)) {
            
            return;
        }

        # Get workspace settings
        $setting = Import-DOKDscWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;

        $nodePath = GetWorkspacePath -WorkspacePath $WorkspacePath -Path $setting.Options.NodePath -Verbose:$VerbosePreference;

        CreatePath -Path $nodePath;

        # Import node data
        $nodeData = ImportNodeData -NodePath $nodePath -InstanceName $InstanceName -Verbose:$VerbosePreference;

        if ($Null -eq $nodeData -or $nodeData.Length -eq 0) {
            Write-Error -Message $LocalizedData.ErrorMissingNodeData -Category ObjectNotFound -TargetObject $nodePath -ErrorAction Stop;
        }

        foreach ($node in $nodeData) {
            # Merge certificate information into node data
            MergeNodeCertificate -InputObject $node -Path $nodePath -InstanceName $node.InstanceName -Verbose:$VerbosePreference;

            # Register the node
            RegisterNode -Node $node -OutputPath $nodePath -Verbose:$VerbosePreference;

            # Copy required modules
            # CopyModules -Session $session -Path '';
        }
    }

    end {
        Write-Verbose -Message "[DOKDsc] END::";
    }
}

function Import-DOKDscNodeConfiguration {

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $False)]
        [String[]]$InstanceName,

        [Parameter(Mandatory = $False)]
        [Alias('Path')]
        [String]$WorkspacePath = $PWD
    )

    begin {
        Write-Verbose -Message "[DOKDsc] BEGIN::";
    }

    process {

        if (!(Test-Path -Path $WorkspacePath)) {
            Write-Error -Message ($LocalizedData.WorkspacePathDoesNotExist) -Category ObjectNotFound -TargetObject $WorkspacePath -ErrorAction Stop;
        }

        # Get workspace settings
        $setting = Import-DOKDscWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;

        $nodePath = GetWorkspacePath -WorkspacePath $WorkspacePath -Path $setting.Options.NodePath -Verbose:$VerbosePreference;

        # Import node data
        $nodeData = ImportNodeData -NodePath $nodePath -InstanceName $InstanceName -Verbose:$VerbosePreference;

        if ($Null -eq $nodeData -or $nodeData.Length -eq 0) {
            Write-Error -Message ($LocalizedData.ErrorMissingNodeData -f $WorkspacePath) -Category ObjectNotFound -ErrorAction Stop;
        }

        foreach ($node in $nodeData) {
            # Merge certificate information into node data
            MergeNodeCertificate -InputObject $node -Path $nodePath -InstanceName $node.InstanceName -Verbose:$VerbosePreference;

            $node.ConfigurationData;
        }
    }

    end {
        Write-Verbose -Message "[DOKDsc] END::";
    }
}

function Get-DOKDscCollection {

    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([DevOpsKitDsc.Workspace.Collection])]
    param (
        [Parameter(Mandatory = $False, ParameterSetName = 'Path')]
        [String]$WorkspacePath = $PWD,

        [Parameter(Mandatory = $True, ParameterSetName = 'Setting')]
        [DevOpsKitDsc.Workspace.WorkspaceSetting]$Workspace,

        [Parameter(Mandatory = $False)]
        [String]$Name
    )

    process {

        $setting = $Workspace;

        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            
            # Get workspace settings
            $setting = Import-DOKDscWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;
        }
        
        $collections = $setting.Collections | Where-Object -FilterScript {
            (!$PSBoundParameters.ContainsKey('Name') -or $Name -contains $_.Name)
        };

        return $collections;
    }
}

function New-DOKDscCollection {

    [CmdletBinding(DefaultParameterSetName = 'Path', SupportsShouldProcess = $True)]
    [OutputType([DevOpsKitDsc.Workspace.Collection])]
    param (
        [Parameter(Mandatory = $False, ParameterSetName = 'Path')]
        [String]$WorkspacePath = $PWD,

        [Parameter(Mandatory = $True, ParameterSetName = 'Workspace')]
        [DevOpsKitDsc.Workspace.WorkspaceSetting]$Workspace,

        [Parameter(Position = 0, Mandatory = $True)]
        [String]$Name,

        [Parameter(Position = 1, Mandatory = $False)]
        [String]$Path
    )

    process {
        # Get workspace settings
        $setting = Import-DOKDscWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;
        
        $filteredConfigurations = $setting.Collections | Where-Object -FilterScript {
            ($Name -eq $_.Name)
        };

        if ($Null -ne $filteredConfigurations) {
            Write-Error -Message $LocalizedData.ConfigurationAlreadyExists -ErrorAction Stop;
        }

        [String]$configurationPath = GetWorkspacePath -WorkspacePath $WorkspacePath -Path $Path;

        # Use default configuration path if not specified
        if ([String]::IsNullOrEmpty($Path)) {
            $configurationPath = GetDefaultConfigurationPath -WorkspacePath $WorkspacePath -Setting $setting -ConfigurationName $Name -Verbose:$VerbosePreference;
        }

        # Check of the configuration script already exists
        if (!(Test-Path -Path $configurationPath)) {
            
            if ($PSCmdlet.ShouldProcess($LocalizedData.CreatingFromTemplate, $configurationPath)) {

                # Create a configuration from a template
                CopyTemplate -Name 'NewConfiguration.ps1' -Path $configurationPath -Verbose:$VerbosePreference;
            }
        }

        $relativePath = GetWorkspacePath -WorkspacePath $WorkspacePath -Path $configurationPath -Relative;

        $c = New-Object -TypeName DevOpsKitDsc.Workspace.Collection -Property @{
            Name = $Name;
            Path = $relativePath;
        };
        
        $setting.Collections.Add($c);

        if ($PSCmdlet.ShouldProcess($LocalizedData.WritingWorkspaceSettings, $WorkspacePath)) {
            WriteWorkspaceSetting -WorkspacePath $WorkspacePath -InputObject $setting -Verbose:$VerbosePreference;
        }

        return $c;
    }
}

function Publish-DOKDscCollection { 

    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $False)]
        [String[]]$Name,

        [Parameter(Mandatory = $False)]
        [Alias('paths')]
        [String]$WorkspacePath = $PWD
    )

    begin {
        $dokOperation = 'Publish';

        Write-Verbose -Message "[DOKDsc][$dokOperation] BEGIN::";
    }

    process {

        # Get workspace settings
        $setting = Import-DOKDscWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;

        Write-Verbose -Message "[DOKDsc][$dokOperation] -- Using Collection: $Name";

        # Filter collections by name as required
        $collections = $setting.Collections | Where-Object -FilterScript {
            !$PSBoundParameters.ContainsKey('Name') -or
            ($Name -contains $_.Name)
        };

        # Process each matching collection
        foreach ($collection in $collections) {

            $outputPath = $setting.Options.OutputPath;
            
            $publishParams = @{
                OutputPath = $outputPath;
                Name = $collection.Name;
            };

            PublishConfiguration @publishParams;
        }
    }

    end {
        Write-Verbose -Message "[DOKDsc][$dokOperation] END::";
    }
}

# Generate a unique .mof configuration document
function Invoke-DOKDscBuild {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False)]
        [String]$Name,

        [Parameter(Mandatory = $False)]
        [String[]]$InstanceName,

        [Parameter(Mandatory = $False)]
        [Alias('Path')]
        [String]$WorkspacePath = $PWD,

        [Parameter(Mandatory = $False)]
        [Object]$ConfigurationData,

        [Parameter(Mandatory = $False)]
        [System.Collections.IDictionary]$Parameters

        # [Parameter(Mandatory = $False)]
        # [Switch]$Wait = $False
    )

    begin {
        $dokOperation = 'Deploy';

        Write-Verbose -Message "[DOKDsc][$dokOperation] BEGIN::";
    }

    process {

        # Get workspace settings
        $setting = Import-DOKDscWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;

        Write-Verbose -Message "[DOKDsc][$dokOperation] -- Using Collection: $Name";
        Write-Verbose -Message "[DOKDsc][$dokOperation] -- Using BuildPath: $outputPath";
        Write-Verbose -Message "[DOKDsc][$dokOperation] -- Using NodePath: $($setting.Options.NodePath)";
        # Write-Verbose -Message "[DOKDsc][$dokOperation] -- Using SourcePath: $($setting.Workspace.SourcePath)";
        Write-Verbose -Message "[DOKDsc][$dokOperation] -- Using ModulePath: $($setting.Options.ModulePath)";

        # # Check if the path exists
        # if (!(Test-Path -Path $nodePath)) {
        #     # No node data to process
        #     return;
        # }

        $configFilterParams = @{ Workspace = $setting; };

        if ($PSBoundParameters.ContainsKey($configFilterParams)) {
            $configFilterParams['Name'] = $Name;
        }

        $collections = Get-DOKDscCollection @configFilterParams -Verbose:$VerbosePreference;
        
        # Process each environment
        foreach ($collection in $collections) {
            
            # Get the output path
            $outputPath = GetWorkspacePath -WorkspacePath $WorkspacePath -Path $setting.Options.OutputPath -ChildPath $collection.Name;

            # Ensure that the output path exists
            $outputPath = CreatePath -Path $outputPath -PassThru -Verbose:$VerbosePreference;

            $sourcePath = (Get-Item -Path $collection.Path).FullName;

            $nodePath = $collection.Nodes;

            if ($Null -ne $nodePath) {
                # Import node data
                $nodeData = ImportNodeData -NodePath $nodePath -InstanceName $InstanceName -Verbose:$VerbosePreference;
                
                foreach ($node in $nodeData) {
                    Write-Verbose -Message "[DOKDsc][$dokOperation] -- Processing node: $($node.InstanceName)";
                    
                    try {
                        # Merge certificate information into node data
                        MergeNodeCertificate -InputObject $node -Path $node.BaseDirectory -InstanceName $node.InstanceName -Verbose:$VerbosePreference;
    
                        MergeConfiguration -InputObject $node -Collection $collection -Verbose:$VerbosePreference;
    
                        # Create job parameters
                        $jobParams = New-Object -TypeName PSObject -Property @{
                            ConfigurationName = $configuration.Name;
                            ConfigurationData = $node.ConfigurationData;
                            Parameters = $Parameters;
                            Path = $sourcePath;
                            OutputPath = $outputPath;
                            ModulePath = [String[]]$setting.Options.ModulePath;
                            AddModulesToSearchPath = $setting.Options.AddModulesToSearchPath;
                        }
    
                        # Start the job
                        # $job = Start-Job -ScriptBlock ${function:BuildConfiguration} -InputObject $jobParams;
    
                        BuildConfiguration -InputObject $jobParams -Verbose:$VerbosePreference;

                        # Build documentation
                        BuildDocumentation -Collection $collection -Path $outputPath -OutputPath $outputPath -Verbose:$VerbosePreference;
                    } catch {
                        Write-Error -Message "Failed to build configuration for $($node.InstanceName). $($_.Exception.Message)";
                    }
                }
            }
        }

        # Wait for the job to return
        # if ($Wait) {
        #     $job | Receive-Job -Wait;
        # } else {
        #     $job;
        # }
    }

    end {
        Write-Verbose -Message "[DOKDsc][$dokOperation] END::";
    }
}

function Publish-DOKDscModule {

    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $False)]
        [String]$WorkspacePath = $PWD,

        [Parameter(Mandatory = $False)]
        [String]$ModuleName,

        [Parameter(Mandatory = $False)]
        [String]$ModuleVersion
    )

    begin {
        $dokOperation = 'Publish';

        Write-Verbose -Message "[DOKDsc][$dokOperation] BEGIN::";
    }

    process {
        
        # Get workspace settings
        $setting = Import-DOKDscWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;
        
        $modules = GetModule -WorkspacePath $WorkspacePath -Workspace $setting -Verbose:$VerbosePreference;

        if ($PSBoundParameters.ContainsKey('ModuleName') -or $PSBoundParameters.ContainsKey('ModuleVersion')) {
            $modules = $modules | Where-Object -FilterScript {
                ([String]::IsNullOrEmpty($ModuleName) -or $ModuleName -eq $_.ModuleName) -and
                ([String]::IsNullOrEmpty($ModuleVerion) -or $ModuleVersion -eq $_.ModuleVersion)
            }

            if ($Null -eq $modules) {
                Write-Error -Message ($LocalizedData.ModuleDoesNotExist) -Category ObjectNotFound -ErrorAction Stop;
            }
        }

        # Process each environment
        foreach ($module in $modules) {

            $outputPath = GetWorkspacePath -WorkspacePath $WorkspacePath -Path $setting.Options.OutputPath;
            
            $publishParams = @{
                Module = $module;
                OutputPath = $outputPath;
            };

            PublishModule @publishParams;
        }
    }

    end {
        Write-Verbose -Message "[DOKDsc][$dokOperation] END::";
    }
}

function Get-DOKDscModule {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False)]
        [String]$WorkspacePath = $PWD,

        [Parameter(Mandatory = $False)]
        [String]$ModuleName,

        [Parameter(Mandatory = $False)]
        [String]$ModuleVersion
    )

    process {

        # Get workspace settings
        $setting = Import-DOKDscWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;

        # Get matching modules
        GetModule -WorkspacePath $WorkspacePath -Workspace $setting -Verbose:$VerbosePreference | Where-Object -FilterScript {
            ([String]::IsNullOrEmpty($ModuleName) -or $_.ModuleName -eq $ModuleName) -and
            ([String]::IsNullOrEmpty($ModuleVersion) -or $_.ModuleVersion -eq $ModuleVersion)
        }
    }
}

function Start-DOKDscSite {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False)]
        [String]$Path = $PWD
    )

    process {

        if (!(Test-Path -Path $Path -PathType Container)) {
            Write-Error -Message 'The path is not valid';

            return;
        }

        # $setting = ReadSetting -Path $Path -Verbose:$VerbosePreference;
        

        docfx "$Path\.docfx\docfx.json" --serve
    }
}

function Publish-DOKDscSite {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False)]
        [String]$WorkspacePath = $PWD
    )

    process {

        # Get workspace settings
        # $setting = Import-DOKDscWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;

        # Generate a docfx.json file

        # Call docfx build
        BuildSite -Path "$WorkspacePath\.docfx\docfx.json" -Verbose:$VerbosePreference;
    }
}

function Initialize-DOKDsc {
    
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $False)]
        [Alias('Path')]
        [String]$WorkspacePath = $PWD,

        # Use to force the creation of the workspace when the path does not exist
        [Parameter(Mandatory = $False)]
        [Switch]$Force = $False
    )

    begin {
        Write-Verbose -Message "[DOKDsc][Init] BEGIN::";
    }

    process {

        # Check if the workspace path exists
        if (!(Test-Path -Path $WorkspacePath)) {

            if ($Force) {

                # Force creation of the workspace path
                New-Item -Path $WorkspacePath -ItemType Directory -Force | Out-Null;
            } else {
                Write-Error -Message ($LocalizedData.WorkspacePathDoesNotExist) -Category ObjectNotFound -TargetObject $WorkspacePath -ErrorAction Stop;
            }
        }

        if (!(HasWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference)) {
            
            # Create settings
            WriteWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;
        }
    }

    end {
        Write-Verbose -Message "[DOKDsc][Init] END::";
    }
}

# Restore workspace modules
function Restore-DOKDscModule {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False)]
        [String]$WorkspacePath = $PWD,

        # The name of the module to restore
        [Parameter(Mandatory = $False)]
        [String]$ModuleName,

        # The version of the module to restore
        [Parameter(Mandatory = $False)]
        [String]$ModuleVersion
    )

    process {

        $setting = Import-DOKDscWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;

        # Get a list of a matching modules
        $modules = GetModule -WorkspacePath $WorkspacePath -Workspace $setting -Verbose:$VerbosePreference | Where-Object -FilterScript {
            ([String]::IsNullOrEmpty($ModuleName) -or $_.ModuleName -eq $ModuleName) -and
            ([String]::IsNullOrEmpty($ModuleVersion) -or $_.ModuleVersion -eq $ModuleVersion)
        }

        # Process each matching module
        foreach ($module in $modules) {

            if ($module.Type -eq 'Workspace') {

            } else {
                RestoreModule -Module $module -OutputPath (GetWorkspacePath -WorkspacePath $WorkspacePath -Path $setting.Options.ModulePath);
            }
        }
    }
}

function Import-DOKDscWorkspaceSetting {

    [CmdletBinding()]
    [OutputType([DevOpsKitDsc.Workspace.WorkspaceSetting])]
    param (
        [Parameter(Mandatory = $False)]
        [Alias('Path')]
        [String]$WorkspacePath = $PWD
    )

    process {

        # Check if the workspace path exists
        if (!(Test-Path -Path $WorkspacePath)) {
            Write-Error -Message ($LocalizedData.WorkspacePathDoesNotExist) -Category ObjectNotFound -TargetObject $WorkspacePath -ErrorAction Stop;
        }

        return ReadWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;
    }
}

function Set-DOKDscWorkspaceOption {

    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $False)]
        [String]$WorkspacePath = $PWD,

        [Parameter(Mandatory = $False)]
        [String]$OutputPath,

        [Parameter(Mandatory = $False)]
        [String]$NodePath
    )

    process {

        # Load current workspace settings
        $setting = ReadWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;

        # Track if settings have been changed
        $settingChanged = $False;

        # Check for OutputPath parameter
        if ($PSBoundParameters.ContainsKey('OutputPath')) {

            # Continue if the parameter is different to the current setting
            if ($OutputPath -ne $setting.Options.OutputPath) {

                # Process WhatIf
                if ($PSCmdlet.ShouldProcess('', '')) {

                    # Update the setting
                    $setting.Options.OutputPath = $OutputPath;

                    # Mark setting as changed
                    $settingChanged = $True;
                }
            }
        }

        # Check for NodePath parameter
        if ($PSBoundParameters.ContainsKey('NodePath')) {

            # Continue if the parameter is different to the current setting
            if ($OutputPath -ne $setting.Options.NodePath) {

                # Process WhatIf
                if ($PSCmdlet.ShouldProcess('', '')) {
                    
                    # Update the setting
                    $setting.Options.NodePath = $NodePath;

                    # Mark setting as changed
                    $settingChanged = $True;
                }
            }
        }

        # Save workspace settings if any changes were made
        if ($settingChanged) {

            # Save workspace settings
            WriteWorkspaceSetting -InputObject $setting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;
        }
    }
}

function Get-DOKDscWorkspaceOption {

    [CmdletBinding()]
    [OutputType([DevOpsKitDsc.Workspace.WorkspaceOption])]
    param (
        [Parameter(Mandatory = $False)]
        [String]$WorkspacePath = $PWD
    )

    process {
        
        # Load current workspace settings
        $setting = ReadWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;

        return $setting.Options;
    }
}

function Add-DOKDscModule {

    [CmdletBinding(DefaultParameterSetName = 'Module')]
    param (
        [Parameter(Mandatory = $False)]
        [String]$WorkspacePath = $PWD,

        [Parameter(Mandatory = $True, ParameterSetName = 'Module')]
        [Alias('Name')]
        [String]$ModuleName,
        
        [Parameter(Mandatory = $True, ParameterSetName = 'Module')]
        [Alias('Version')]
        [String]$ModuleVersion,

        [Parameter(Mandatory = $False, ParameterSetName = 'Module')]
        [String]$Repository,

        [Parameter(Mandatory = $True, ParameterSetName = 'Path')]
        [String]$Path,

        [Parameter(Mandatory = $False)]
        [ValidateSet('Workspace', 'Repository')]
        [String]$Type
    )

    begin {
        # Track if settings have been changed
        $settingChanged = $False;

        # Load current workspace settings
        $setting = ReadWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;
    }

    process {        

        $moduleProps = @{ };

        if ($PSBoundParameters.ContainsKey('ModuleName')) {
            $moduleProps['ModuleName'] = $ModuleName;
        }

        if ($PSBoundParameters.ContainsKey('ModuleVersion')) {
            $moduleProps['ModuleVersion'] = $ModuleVersion;
        }

        if ($PSBoundParameters.ContainsKey('Repository')) {
            $moduleProps['Repository'] = $Repository;
        }

        if ($PSCmdlet.ParameterSetName -eq 'Path') {

            # Read the module manifest
            $manifestPath = GetWorkspacePath -WorkspacePath $WorkspacePath -Path $Path;
            $manifestName = Split-Path -Path $manifestPath -Leaf;
            Import-LocalizedData -BindingVariable moduleData -BaseDirectory $manifestPath -FileName "$manifestName.psd1";

            $moduleProps['ModuleName'] = $manifestName;
            $moduleProps['ModuleVersion'] = $moduleData.ModuleVersion;

            $moduleProps['Path'] = $Path;
        }

        if ($PSBoundParameters.ContainsKey('Type')) {
            $moduleProps['Type'] = $Type;
        }

        if (AddModuleToWorkspace -Setting $setting @moduleProps -Verbose:$VerbosePreference) {
            $settingChanged = $True;
        }
    }

    end {
        if ($settingChanged) {
            WriteWorkspaceSetting -WorkspacePath $WorkspacePath -InputObject $setting -Verbose:$VerbosePreference;
        }
    }
}

function Compress-DOKDscWorkspaceModule {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $False)]
        [Alias('Path')]
        [String]$WorkspacePath = $PWD
    )

    process {

        # Check that the workspace path exists
        if (!(Test-Path -Path $WorkspacePath)) {
            Write-Error -Message ($LocalizedData.WorkspacePathDoesNotExist -f $WorkspacePath) -Category ObjectNotFound;
            
            return;
        }

        # Get workspace settings
        $setting = Import-DOKDscWorkspaceSetting -WorkspacePath $WorkspacePath -Verbose:$VerbosePreference;

        # Check modules and restore as required
        foreach ($module in $setting.Modules) {

            # 
            PackageModule -Module $module -Format AzureAutomationService -ModulePath $setting.Options.ModulePath -Verbose:$VerbosePreference;
        }
    }
}

#endregion Public functions

#
# Helper functions
#

#region Helper functions

function RegisterNode {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [PSObject]$Node,

        [Parameter(Mandatory = $True)]
        [String]$OutputPath
    )

    process {
        $sessionParams = @{
            ComputerName = $Node.InstanceName
        };

        if ($Node.InstanceName -eq 'localhost' -or $Node.InstanceName -eq $Env:COMPUTERNAME) {
            $sessionParams['EnableNetworkAccess'] = $True;
        }

        $session = New-PSSession @sessionParams;

        # Setup the encryption certificate
        TryDscEncryptionCertificate -Session $session -Path $OutputPath -Verbose:$VerbosePreference | Out-Null;
    }
}

# Create a public/private keypair as required
function TryDscEncryptionCertificate {

    [CmdletBinding()]
    [OutputType([Security.Cryptography.X509Certificates.X509Certificate2])]
    param (
        # A remoting session to connect to
        [Parameter(Mandatory = $True)]
        [System.Management.Automation.Runspaces.PSSession]$Session,

        # The path to save the encryption public key to
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {

        # Try to get the encryption certificate
        $certificate = Invoke-Command -Session $Session -ScriptBlock ${function:GetCertificate};

        # Create a new encryption certificate as required
        if ($Null -eq $certificate) {
            $certificate = Invoke-Command -Session $Session -ScriptBlock ${function:NewCertificate};
        } else {
            Write-Verbose -Message ($LocalizedData.HasEncryptionCertificate -f $Session.ComputerName, $certificate.Thumbprint);
        }

        if ($Null -eq $certificate) {
            return $Null;
        }

        # Strongly type the result
        $result = New-Object -TypeName Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(,$certificate.GetRawCertData());

        $result | Export-Certificate -FilePath "$Path\$($Session.ComputerName).cer" -Force;

        # Return the certificate
        return $result;
    }
}

function GetCertificate {

    [CmdletBinding()]
    param (
        
    )

    process {
        # Get the DSC encryption certificate with the longest lifetime
        Get-ChildItem -Path 'Certificate::LocalMachine\My' | Where-Object -FilterScript {
            $_.FriendlyName -eq 'DSC Credential Encryption'
        } | Sort-Object -Property NotAfter -Descending | Select-Object -First 1;
    }
}

function NewCertificate {

    [CmdletBinding()]
    param (
        
    )

    process {
        # Subject processing

        [String]$Subject = "CN=$Env:COMPUTERNAME";

        # http://msdn.microsoft.com/en-us/library/aa377051(VS.85).aspx
        $SubjectDN = New-Object -ComObject X509Enrollment.CX500DistinguishedName;
        $SubjectDN.Encode($Subject, 0x0);

        # SANs
        New-Variable -Name OtherName -Value 0x1 -Option Constant
        New-Variable -Name RFC822Name -Value 0x2 -Option Constant
        New-Variable -Name DNSName -Value 0x3 -Option Constant
        New-Variable -Name DirectoryName -Value 0x5 -Option Constant
        New-Variable -Name URL -Value 0x7 -Option Constant
        New-Variable -Name IPAddress -Value 0x8 -Option Constant
        New-Variable -Name RegisteredID -Value 0x9 -Option Constant
        New-Variable -Name Guid -Value 0xa -Option Constant
        New-Variable -Name UPN -Value 0xb -Option Constant
        New-Variable -Name AllowUntrustedCertificate -Value 0x2 -Option Constant

        New-Variable -Name Base64 -Value 0x1 -Option Constant

        $certificateExtensions = @();

        # Enhanced key usage

        $EnhancedKeyUsage = [Security.Cryptography.Oid]'Document Encryption';
        
        [Security.Cryptography.X509Certificates.X509KeyUsageFlags]$KeyUsage = 'KeyEncipherment, DataEncipherment';
        [String[]]$SubjectAlternativeName = $Env:COMPUTERNAME;
        $ProviderName = 'Microsoft Enhanced Cryptographic Provider v1.0';
        $AlgorithmName = 'RSA';
        $SignatureAlgorithm = 'SHA256';
        $KeyLength = 2048;
        [String]$FriendlyName = 'DSC Credential Encryption';
        $Description = 'This is an encryption certificate for DSC.';

        [datetime]$NotBefore = [DateTime]::Now.AddDays(-1);
		[datetime]$NotAfter = $NotBefore.AddDays(365);
        
        $OIDs = New-Object -ComObject X509Enrollment.CObjectIDs;

        $OID = New-Object -ComObject X509Enrollment.CObjectID;
        $OID.InitializeFromValue($EnhancedKeyUsage.Value);
        # http://msdn.microsoft.com/en-us/library/aa376785(VS.85).aspx
        $OIDs.Add($OID);
		

		# http://msdn.microsoft.com/en-us/library/aa378132(VS.85).aspx
		$EKU = New-Object -ComObject X509Enrollment.CX509ExtensionEnhancedKeyUsage;
		$EKU.InitializeEncode($OIDs);
        $certificateExtensions += $EKU;

        # Build key usage extension
        $keyUsageExtension = New-Object -ComObject X509Enrollment.CX509ExtensionKeyUsage;
        $keyUsageExtension.InitializeEncode([int]$KeyUsage);
        $keyUsageExtension.Critical = $True;
        $certificateExtensions += $keyUsageExtension;

        # SAN

        if ($SubjectAlternativeName) {

            $SAN = New-Object -ComObject X509Enrollment.CX509ExtensionAlternativeNames
            $Names = New-Object -ComObject X509Enrollment.CAlternativeNames

            foreach ($altname in $SubjectAlternativeName) {

                $Name = New-Object -ComObject X509Enrollment.CAlternativeName
                if ($altname.Contains("@")) {
                    $Name.InitializeFromString($RFC822Name,$altname)
                } else {
                    try {
                        $Bytes = [Net.IPAddress]::Parse($altname).GetAddressBytes()
                        $Name.InitializeFromRawData($IPAddress,$Base64,[Convert]::ToBase64String($Bytes))
                    } catch {
                        try {
                            $Bytes = [Guid]::Parse($altname).ToByteArray()
                            $Name.InitializeFromRawData($Guid,$Base64,[Convert]::ToBase64String($Bytes))
                        } catch {
                            try {
                                $Bytes = ([Security.Cryptography.X509Certificates.X500DistinguishedName]$altname).RawData
                                $Name.InitializeFromRawData($DirectoryName,$Base64,[Convert]::ToBase64String($Bytes))
                            } catch {$Name.InitializeFromString($DNSName,$altname)}
                        }
                    }
                }
                $Names.Add($Name)
            }

            $SAN.InitializeEncode($Names)
            # $ExtensionsToAdd += "SAN"

            $certificateExtensions += $SAN;
        }

        # Get private key algorithm OID
        $algorithmOid = New-Object -ComObject X509Enrollment.CObjectId;
        $algorithmOid.InitializeFromValue(([Security.Cryptography.Oid]$AlgorithmName).Value);

        # Get signature algorithm OID
        $signatureOid = New-Object -ComObject X509Enrollment.CObjectId;
        $signatureOid.InitializeFromValue(([Security.Cryptography.Oid]$SignatureAlgorithm).Value);

        # Generate a private key

        # http://msdn.microsoft.com/en-us/library/aa378921(VS.85).aspx
        $privateKey = New-Object -ComObject X509Enrollment.CX509PrivateKey;
        $privateKey.ProviderName = $ProviderName;
        $privateKey.Algorithm = $algorithmOid;

        # http://msdn.microsoft.com/en-us/library/aa379409(VS.85).aspx
        $privateKey.KeySpec = 1; # Exchange
        $privateKey.Length = $KeyLength;
        $privateKey.MachineContext = $True;
        $privateKey.ExportPolicy = 0; # Not exportable
        $privateKey.Create();

        # Build the certificate request

        # http://msdn.microsoft.com/en-us/library/aa377124(VS.85).aspx
        $csr = New-Object -ComObject X509Enrollment.CX509CertificateRequestCertificate;
        $csr.InitializeFromPrivateKey(0x2, $privateKey, '');

        # Set certificate fields
        $csr.Subject = $SubjectDN;
        $csr.Issuer = $csr.Subject;
        $csr.NotBefore = $NotBefore;
        $csr.NotAfter = $NotAfter;

        # Add certificate extensions
        foreach ($item in $certificateExtensions) {
            $csr.X509Extensions.Add($item);
        };

        # if (![string]::IsNullOrEmpty($SerialNumber)) {
        #     if ($SerialNumber -match "[^0-9a-fA-F]") {throw "Invalid serial number specified."}
        #     if ($SerialNumber.Length % 2) {$SerialNumber = "0" + $SerialNumber}
        #     $Bytes = $SerialNumber -split "(.{2})" | Where-Object {$_} | ForEach-Object{[Convert]::ToByte($_,16)}
        #     $ByteString = [Convert]::ToBase64String($Bytes)
        #     $Cert.SerialNumber.InvokeSet($ByteString,1)
        # }

        $csr.SignatureInformation.HashAlgorithm = $signatureOid;

        # Completing certificate request template building
        $csr.Encode();
        
        # interface: http://msdn.microsoft.com/en-us/library/aa377809(VS.85).aspx
        $certificateEnrollment = New-Object -ComObject X509Enrollment.CX509enrollment;
        $certificateEnrollment.InitializeFromRequest($csr);
        $certificateEnrollment.CertificateFriendlyName = $FriendlyName;
        $certificateEnrollment.CertificateDescription = $Description;

        # Create the request with base64 encoding
        $endCert = $certificateEnrollment.CreateRequest(0x1);

        # Install the certificate response
        $certificateEnrollment.InstallResponse(
            0x2, # Allow untrusted, this self-signed certificate will not chain to a trust root
            $endCert,
            0x1, # Use base64 encoding
            ''
        );

        [Byte[]]$CertBytes = [Convert]::FromBase64String($endCert);

        New-Object Security.Cryptography.X509Certificates.X509Certificate2 @(,$CertBytes);
    }
}

function CopyModules {

    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $True)]
        [System.Management.Automation.Runspaces.PSSession]$Session,

        # The source path for the modules
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {
        # Copy the module paths into the session
        Copy-Item -ToSession $Session -Path $Path -Destination 'C:\Program Files\WindowsPowerShell\Modules\' -Recurse -Force;
    }
}

function BuildConfiguration {

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $True)]
        [PSObject]$InputObject
    )

    process {

        Write-Verbose -Message "[DOKDsc][$dokOperation] -- Building configuration";
        
        $Path = $InputObject.Path;
        $OutputPath = $InputObject.OutputPath;
        $ModulePath = $InputObject.ModulePath;
        $ConfigurationData = $InputObject.ConfigurationData;
        $Parameters = $InputObject.Parameters;
        $AddModulesToSearchPath = $InputObject.AddModulesToSearchPath;

        $currentPSModulePath = $Env:PSModulePath;

        try {

            if (![String]::IsNullOrEmpty($ModulePath) -and $AddModulesToSearchPath) {
                $Env:PSModulePath = "$Env:SystemRoot\System32\WindowsPowerShell\v1.0\Modules;$([String]::Join(';', $ModulePath))";

                Write-Verbose -Message "[DOKDsc][$dokOperation] -- Using PSModulePath: $($Env:PSModulePath)";
                # [System.Environment]::SetEnvironmentVariable('PSModulePath', "$Env:SystemRoot\System32\WindowsPowerShell\v1.0\Modules;$ModulePath", 'Process')
            }

            $configurationScript = "$Path";

            Write-Verbose -Message "[DOKDsc][$dokOperation] -- Using configuration script: $configurationScript";

            if (!(Test-Path -Path $configurationScript)) {
                Write-Error -Message "Failed to find configuration script: $configurationScript";
            }

            # By default use the base name of the file as the configuration name
            $scriptItem = Get-Item -Path $configurationScript;
            $configurationName = $scriptItem.BaseName;

            if (![String]::IsNullOrEmpty($InputObject.ConfigurationName)) {
                $configurationName = $InputObject.ConfigurationName;
            }

            Write-Verbose -Message "[DOKDsc][$dokOperation] -- Using configuration name: $ConfigurationName";

            Write-Verbose -Message "[DOKDsc][$dokOperation] -- Using OutputPath: $OutputPath";

            $configParams = @{ OutputPath = $OutputPath; };

            # Bind configuration data
            if ($Null -ne $ConfigurationData) {
                $configParams.Add('ConfigurationData', $ConfigurationData);
            }

            # Bind parameters
            if ($Null -ne $Parameters) {
                $configParams += $Parameters;
            }

            . "$configurationScript";

            $buildResult = & $ConfigurationName @configParams;

            if ($Null -ne $buildResult -and $buildResult -is [System.IO.FileInfo]) {
                Write-Verbose -Message "[DOKDsc][$dokOperation] -- Generating checksum: $($buildResult.FullName)";

                New-DscChecksum -Path $buildResult.FullName -Force | Out-Null;
            }
        } catch {
            Write-Error -Message "Failed to build configuration for node. $($_.Exception.Message)" -Exception $_.Exception;
        } finally {

            if (![String]::IsNullOrEmpty($ModulePath) -and $AddModulesToSearchPath) {
                $Env:PSModulePath = $currentPSModulePath;

                # [System.Environment]::SetEnvironmentVariable('PSModulePath', "$currentPSModulePath", 'Process')
            }
        }
    }
}

function ImportNodeData {

    [CmdletBinding()]
    [OutputType([PSObject[]])]
    param (
        [Parameter(Mandatory = $True)]
        [String[]]$NodePath,

        [Parameter(Mandatory = $False)]
        [AllowEmptyCollection()]
        [AllowNull()]
        [String[]]$InstanceName = $Null
    )

    process {

        Write-Verbose -Message "[DOKDsc][$dokOperation] -- $($LocalizedData.ImportNodeData -f $NodePath)";

        foreach ($path in $NodePath) {

            # Check if the path exists
            if (!(Test-Path -Path $path)) {

                # if ($PSBoundParameters.ContainsKey('InstanceName')) {
                #     Write-Error -Message ($LocalizedData.ErrorMissingNodeData -f $NodePath) -Category ObjectNotFound;
                # }

                # No node data to process
                # return $Null;
            }

            $pathFilter = Join-Path -Path $path -ChildPath '/';

            $result = Get-ChildItem -Path $pathFilter -File | Where-Object -FilterScript {
                ($Null -eq $InstanceName -or $InstanceName.Count -eq 0) -or $InstanceName -contains $_.BaseName
            } | ForEach-Object -Process {
                $item = $_;

                $dataFilePath = $item.FullName;

                Write-Verbose -Message "[DOKDsc][$dokOperation] -- $($LocalizedData.FoundNodeData -f $dataFilePath)";

                if ($item.Extension -eq '.psd1') {

                    # Process .psd1 file
                    ReadPSNodeData -Path $dataFilePath -Verbose:$VerbosePreference;
                }
                elseif ($item.Extension -eq '.json') {

                    # Process .json file
                    ReadJsonNodeData -Path $dataFilePath -Verbose:$VerbosePreference;
                }
            }

            $result;
        }
    }
}

# Read node data from a .psd1 file.
function ReadPSNodeData {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {
        Write-Verbose -Message "[DOKDsc][$dokOperation] -- Reading node data from $Path";
        
        $baseDirectory = Split-Path -Path $Path -Parent;
        $fileName = Split-Path -Path $Path -Leaf;

        $results = @{ };

        # Read the .psd1 file
        Import-LocalizedData -BaseDirectory $baseDirectory -FileName $fileName -BindingVariable psdFile;

        # Detect if compatible format should be used.
        if ($psdFile.ContainsKey('AllNodes')) {

            foreach ($node in $psdFile.AllNodes) {

                # Create result object
                $result = New-Object -TypeName PSObject -Property @{
                    InstanceName = $node.NodeName;
                    BaseDirectory = $baseDirectory;
                    ConfigurationData = @{ AllNodes = @($node); };
                }

                $results.Add($result.InstanceName, $result);
            }
        } else {

            # Create result object
            $result = New-Object -TypeName PSObject -Property @{
                InstanceName = $psdFile.NodeName;
                BaseDirectory = $baseDirectory;
                ConfigurationData = $psdFile;
            }

            $results.Add($result.InstanceName, $result);
        }

        # Emit result objects to pipeline
        $results.Values;
    }
}

# Read node data from a .json file.
function ReadJsonNodeData {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {

        Write-Verbose -Message "[DOKDsc][$dokOperation] -- Reading node data from $Path";

        $baseDirectory = Split-Path -Path $Path -Parent;

        $results = @{ };
        
        # Convert object properties to a hashtable
        function ObjectToHashtable {

            param (
                [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
                [PSObject]$InputObject
            )

            process {
                $result = @{ };

                # Process each property
                $InputObject.PSObject.Properties.GetEnumerator() | ForEach-Object -Process {

                    if ($_.Value -is [Object[]] -and $_.Value[0] -is [String]) {
                        $result[$_.Name] = $_.Value;
                    } elseif ($_.Value -is [Object[]]) {
                        $result[$_.Name] = $_.Value | ObjectToHashtable;
                    } elseif ($_.Value -is [PSCustomObject]) {
                        $result[$_.Name] = ObjectToHashtable -InputObject $_.Value;
                    } else {
                        $result[$_.Name] = $_.Value;
                    }
                }

                $result;
            }
        }
        
        # Read the .json file in as a hashtable
        $jsonFile = Get-Content -Path $Path | ConvertFrom-Json | ObjectToHashtable;

        # Detect if compatible format should be used.
        if ($jsonFile.ContainsKey('AllNodes')) {

            foreach ($node in $jsonFile.AllNodes) {

                # Create result object
                $result = New-Object -TypeName PSObject -Property @{
                    InstanceName = $node.NodeName;
                    BaseDirectory = $baseDirectory;
                    ConfigurationData = @{ AllNodes = @($node); };
                }

                $results.Add($result.InstanceName, $result);
            }
        } else {

            # Create result object
            $result = New-Object -TypeName PSObject -Property @{
                InstanceName = $jsonFile.NodeName;
                BaseDirectory = $baseDirectory;
                ConfigurationData = $jsonFile;
            }

            $results.Add($result.InstanceName, $result);
        }

        # Emit result objects to pipeline
        $results.Values;
    }
}

# Merge encryption certificate data
function MergeNodeCertificate {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$InputObject,

        [Parameter(Mandatory = $True)]
        [String]$Path,

        [Parameter(Mandatory = $True)]
        [String]$InstanceName,

        [Parameter(Mandatory = $False)]
        [Switch]$PassThru = $False
    )

    process {
        
        Write-Verbose -Message "[DOKDsc][$dokOperation]`t-- Merging node public key: $InstanceName";

        $certificateFile = Join-Path -Path $Path -ChildPath "$InstanceName.cer";

        if (Test-Path -Path $certificateFile) {
            $InputObject.ConfigurationData.AllNodes[0]['CertificateFile'] = $certificateFile;
            $InputObject.ConfigurationData.AllNodes[0]['Thumbprint'] = (ExtractCertificateThumbprint -Path $certificateFile -Verbose:$VerbosePreference);

            Write-Verbose -Message "Using certificate: $($InputObject.ConfigurationData.AllNodes[0]['CertificateFile'])";
            Write-Verbose -Message "Using thumbprint: $($InputObject.ConfigurationData.AllNodes[0]['Thumbprint'])";
        } else {
            Write-Warning -Message ($LocalizedData.NoEncryptionCertificate -f $InstanceName);
        }

        if ($PassThru) {
            return $InputObject;
        }
    }
}

function MergeConfiguration {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [PSObject]$InputObject,

        [Parameter(Mandatory = $True)]
        [DevOpsKitDsc.Workspace.Collection]$Collection,

        [Parameter(Mandatory = $False)]
        [Switch]$PassThru = $False
    )

    begin {
        Write-Verbose -Message "[DOKDsc][MergeConfiguration] BEGIN::";
    }

    process {

        # Check if any configuration data was specified
        if ($Null -ne $Collection.Data -and $Collection.Data.Count -gt 0) {

            # Process each key value pair
            foreach ($kv in $Collection.Data.GetEnumerator()) {

                # Only replace the configuration data from the node if ReplaceNodeData = true, or the key didn't exist
                if ($Null -eq $Collection.Options -or $Collection.Options.ReplaceNodeData -or !$InputObject.ConfigurationData.AllNodes[0].ContainsKey($kv.Key)) {

                    Write-Verbose -Message "[DOKDsc][MergeConfiguration] -- Setting $($kv.Key): $($kv.Value)";

                    $InputObject.ConfigurationData.AllNodes[0][$kv.Key] = $kv.Value;
                }
            }
        }

        if ($PassThru) {
            return $InputObject;
        }
    }

    end {
        Write-Verbose -Message "[DOKDsc][MergeConfiguration] END::";
    }
}

function ExtractCertificateThumbprint {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {

        Write-Verbose -Message "Extracting for $Path";


        $certificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @($Path);

        return $certificate.Thumbprint;
    }
}

function CreatePath {

    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path,

        [Switch]$File = $False,

        [Parameter(Mandatory = $False)]
        [Switch]$PassThru = $False
    )

    process {

        if ($File) {
            $Path = Split-Path -Path $Path -Parent;
        }

        if (!(Test-Path -Path $Path)) {
            New-Item -Path $Path -ItemType Directory -Force | Out-Null;
        }

        if ($PassThru) {
            $result = (Get-Item -Path $Path).FullName;

            return $result;
        }
    }
}

function PublishConfiguration {

    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Name,

        [Parameter(Mandatory = $True)]
        [String]$Path,

        [Parameter(Mandatory = $True)]
        [String]$OutputPath
    )

    process {


        if (!(Test-Path -Path $Path)) {
            Write-Error -Message "The specified configuration does not exist.";

            return;
        }

        Copy-Item -LiteralPath $Path -Destination $OutputPath -Force;

    }
}

function PublishModule {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [DevOpsKitDsc.Workspace.Module]$Module,

        [Parameter(Mandatory = $True)]
        [String]$OutputPath
    )

    process {

        # # Read the .psd1 file
        # Import-LocalizedData -BaseDirectory $baseDirectory -FileName $fileName -BindingVariable nodeConfigData;

        $publishName = "$OutputPath\$($Module.ModuleName).zip";

        if (!(Test-Path -Path $OutputPath)) {
            New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null;
        }

        Compress-Archive -Path "$($Module.Path)\*" -DestinationPath $publishName -Verbose -Force;
    }
}

function GetModule {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$WorkspacePath,
        
        [Parameter(Mandatory = $True)]
        [DevOpsKitDsc.Workspace.WorkspaceSetting]$Workspace
    )

    process {

        $modulesPath = GetWorkspacePath -WorkspacePath $WorkspacePath -Path $Workspace.Options.ModulePath;

        foreach ($m in $Workspace.Modules) {

            if ([String]::IsNullOrEmpty($m.Path)) {
                # Calculate and updates the module path
                $m.Path = "$modulesPath\$($m.ModuleName)\$($m.ModuleVersion)";
            } else {
                $m.Path = GetWorkspacePath -WorkspacePath $WorkspacePath -Path $m.Path;
            }

            # Emit the module back to the pipeline
            $m;
        }
    }
}

function BuildDocumentation {

    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $True)]
        [DevOpsKitDsc.Workspace.Collection]$Collection,

        # The path to the .mof file
        [Parameter(Mandatory = $True)]
        [String]$Path,

        # The output path to store documentaion
        [Parameter(Mandatory = $True)]
        [String]$OutputPath
    )

    begin {
        Write-Verbose -Message "[DOKDsc][$dokOperation][Doc]::BEGIN";
    }

    process {

        # Only generate documentation if a template has been set
        if ($Null -eq $Collection.Docs -or [String]::IsNullOrEmpty($Collection.Docs.Path)) {
            Write-Verbose -Message "[DOKDsc][$dokOperation][Doc] -- Skipping documentation, template not set";

            return;
        }

        Invoke-DscNodeDocument -DocumentName $Collection.Docs.Name -Script $Collection.Docs.Path -Path $Path -OutputPath $OutputPath -Verbose:$VerbosePreference;

        # Write-Verbose -Message "[DOKDsc][$dokOperation] -- Update TOC: $($buildResult.FullName)";

        # Update TOC
        UpdateToc -OutputPath $OutputPath -Verbose:$VerbosePreference;
    }

    end {
        Write-Verbose -Message "[DOKDsc][$dokOperation][Doc]::END";
    }
}

function UpdateToc {

    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$OutputPath
    )

    begin {

        Write-Verbose -Message "[DOKDsc][$dokOperation][Toc]::BEGIN";

        # Get markdown content files
        $contentFilePath = @((Get-ChildItem -Path $OutputPath -File | Where-Object -FilterScript {
            $_.FullName -like '*.md' -and $_.Name -ne 'TOC.md'
        }).FullName);

        $toc = @('# Nodes');

        # Read each file and extract metadata
        foreach ($file in $contentFilePath) {
            $contentHeader = ReadYamlHeader -Path $file -Verbose:$VerbosePreference;

            $href = Split-Path -Path $file -Leaf;
            $title = $href -replace '\.md', '';

            if ($Null -ne $contentHeader -and $contentHeader.ContainsKey('title')) {
                $title = $contentHeader.title;
            }

            $toc += "## [$title]($href)";
        }

        $toc | Set-Content -Path "$OutputPath\TOC.md";

        Write-Verbose -Message "[DOKDsc][$dokOperation][Toc]::END";
    }
}

function ReadYamlHeader {

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {

        # Read the file
        $content = Get-Content -Path $Path -Raw;

        # Detect Yaml header
        if (![String]::IsNullOrEmpty($content) -and $content -match '^(---\r\n(?<yaml>([A-Z0-9]{1,}:[A-Z0-9 ]{1,}(\r\n){0,}){1,})\r\n---\r\n)') {

            Write-Verbose -Message "[DscDocs][Toc]`t-- Reading Yaml header: $Path";

            # Extract yaml header key value pair
            [String[]]$yamlHeader = $Matches.yaml -split "`n";

            $result = @{ };

            # Read key values into hashtable
            foreach ($item in $yamlHeader) {
                $kv = $item.Split(':', 2, [System.StringSplitOptions]::RemoveEmptyEntries);

                Write-Debug -Message "Found yaml keypair from: $item";

                if ($kv.Length -eq 2) {
                    $result[$kv[0].Trim()] = $kv[1].Trim();
                }
            }

            # Emit result to the pipeline
            return $result;
        }
    }
}

function BuildSite {

    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {

        docfx.exe build $Path;
    }
}

function HasWorkspaceSetting {

    [CmdletBinding()]
    [OutputType([DevOpsKitDsc.Workspace.WorkspaceSetting])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$WorkspacePath
    )

    process {
        $settingsPath = Join-Path -Path $WorkspacePath -ChildPath '\.dokd\settings.json';
        
        return (Test-Path -Path $settingsPath); 
    }
}

function ReadWorkspaceSetting {

    [CmdletBinding()]
    [OutputType([DevOpsKitDsc.Workspace.WorkspaceSetting])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$WorkspacePath
    )

    process {

        $settingsPath = Join-Path -Path $WorkspacePath -ChildPath '\.dokd\settings.json';

        if (!(Test-Path -Path $settingsPath)) {
            return [DevOpsKitDsc.Workspace.WorkspaceHelper]::LoadDefault();
        }

        $settingsPath = Resolve-Path -Path $settingsPath;

        Write-Verbose -Message "[DOKDsc][$dokOperation] -- Loading workspace from: $WorkspacePath";

        $result = [DevOpsKitDsc.Workspace.WorkspaceHelper]::LoadFrom($settingsPath);

        if ($Null -eq $result) {
            return [DevOpsKitDsc.Workspace.WorkspaceHelper]::LoadDefault();
        }

        return $result;
    }
}

function WriteWorkspaceSetting {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$WorkspacePath,

        [Parameter(Mandatory = $False)]
        [DevOpsKitDsc.Workspace.WorkspaceSetting]$InputObject = [DevOpsKitDsc.Workspace.WorkspaceHelper]::LoadDefault()
    )

    process {

        $dokdPath = Join-Path -Path $WorkspacePath -ChildPath '\.dokd';

        $settingsPath = Join-Path -Path $dokdPath -ChildPath '\settings.json';

        if (!(Test-Path -Path $dokdPath)) {
            New-Item -Path $dokdPath -ItemType Directory -Force | Out-Null;
        }

        [DevOpsKitDsc.Workspace.WorkspaceHelper]::SaveTo($settingsPath, $InputObject);
    }
}

function AddModuleToWorkspace {

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $True)]
        [DevOpsKitDsc.Workspace.WorkspaceSetting]$Setting,

        [Parameter(Mandatory = $True)]
        [String]$ModuleName,

        [Parameter(Mandatory = $True)]
        [String]$ModuleVersion,

        [Parameter(Mandatory = $False)]
        [String]$Repository,

        [Parameter(Mandatory = $False)]
        [String]$Path,

        [Parameter(Mandatory = $False)]
        [String]$Type
    )

    process {


        $moduleObject = New-Object -TypeName DevOpsKitDsc.Workspace.Module -Property @{
            ModuleName = $ModuleName
            ModuleVersion = $ModuleVersion
        };

        if ($PSBoundParameters.ContainsKey('Repository')) {
            $moduleObject.Repository = $Repository;
        }

        if ($PSBoundParameters.ContainsKey('Path')) {
            $moduleObject.Path = $Path;
        }

        if ($PSBoundParameters.ContainsKey('Type')) {
            $moduleObject.Type = $TYpe;
        }

        $Setting.Modules.Add($moduleObject);

        return $True;
    }
}

function RestoreModule {

    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $True)]
        [DevOpsKitDsc.Workspace.Module]$Module,

        [Parameter(Mandatory = $True)]
        [String]$OutputPath
    )

    process {

        Write-Verbose -Message "[DOKDsc][$dokOperation] -- Restoring module: $Module";

        # Check if the module has already been saved to the modules path
        $moduleLocation = Join-Path -Path $OutputPath -ChildPath "$($Module.ModuleName)\$($Module.ModuleVersion)";

        if (!(Test-Path -Path "$moduleLocation\$($Module.ModuleName).ps*" -Include '*.psm1', '*.psd1')) {
            
            try {
                SaveModule -Module $Module -OutputPath $OutputPath -ErrorAction Stop;
            }
            catch {
                Write-Error -Message ($LocalizedData.ModuleRestoreError -f $Module.ModuleName, $_.Exception.Message) -Exception $_.Exception -Category ObjectNotFound;
            }
            
        } else {
            Write-Verbose -Message "[DOKDsc][$dokOperation] -- Module already exists: $Module";
        }
    }
}

function SaveModule {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [DevOpsKitDsc.Workspace.Module]$Module,

        [Parameter(Mandatory = $True)]
        [String]$OutputPath
    )

    process {

        $moduleFilter = @{ Name = $Module.ModuleName; RequiredVersion = $Module.ModuleVersion; Path = $OutputPath; };

        if (![String]::IsNullOrEmpty($Module.Repository)) {
            $moduleFilter.Add('Repository', $Module.Repository);
        }

        Save-Module @moduleFilter;
    }
}

# Compress a specific module for either a Pull Server or Azure Automation Service
function PackageModule {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [DevOpsKitDsc.Workspace.Module]$Module,

        [Parameter(Mandatory = $True)]
        [ValidateSet('AzureAutomationService')]
        [String]$Format,

        [Parameter(Mandatory = $True)]
        [String]$ModulePath
    )

    begin {
        Write-Verbose -Message "[DOKDsc][PackageModule]`tBEGIN::";
    }

    process {

        Write-Verbose -Message "[DOKDsc][PackageModule] -- Packaging module: $Module";

        if ($Format -eq 'AzureAutomationService') {
            
            

        }
    }

    end {
        Write-Verbose -Message "[DOKDsc][PackageModule]`tEND::";
    }
}

function GetWorkspacePath {

    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$WorkspacePath,

        [Parameter(Mandatory = $False)]
        [String]$Path,

        [Parameter(Mandatory = $False)]
        [String]$ChildPath,

        [Parameter(Mandatory = $False)]
        [Switch]$Relative = $False
    )

    process {

        $result = $Path;

        $WorkspacePath = Resolve-Path -Path $WorkspacePath;

        if (![System.IO.Path]::IsPathRooted($Path)) {
            $result = Join-Path -Path $WorkspacePath -ChildPath $Path;
        }

        if ($PSBoundParameters.ContainsKey('ChildPath') -and ![String]::IsNullOrEmpty($ChildPath)) {
            $result = Join-Path -Path $result -ChildPath $ChildPath;
        }

        # Make the path relative to workspace path
        if ($Relative) {
            
            if ($result.Contains($WorkspacePath)) {
                
                $result = $result.Replace($WorkspacePath, '.');
            }

        }

        return $result;
    }
}

function CopyTemplate {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Name,

        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {

        $templateFilePath = Join-Path -Path $PSScriptRoot -ChildPath "Templates\$Name";

        CreatePath -Path $configurationPath -File;

        Set-Content -Path $configurationPath -Value (Get-Content -Path $templateFilePath);
    }
}

function GetDefaultConfigurationPath {

    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$WorkspacePath,

        [Parameter(Mandatory = $True)]
        [DevOpsKitDsc.Workspace.WorkspaceSetting]$Setting,

        [Parameter(Mandatory = $True)]
        [String]$ConfigurationName
    )

    process {

        return GetWorkspacePath -WorkspacePath $WorkspacePath -Path "src\Configuration\$ConfigurationName.ps1";
    }
}

#endregion Helper functions

#
# Export module
#

New-Alias -Name 'dokd-init' -Value 'Initialize-DOKDsc';
New-Alias -Name 'dokd-restore' -Value 'Restore-DOKDscModule';
New-Alias -Name 'dokd-new' -Value 'New-DOKDscCollection';
New-Alias -Name 'dokd-build' -Value 'Invoke-DOKDscBuild';

Export-ModuleMember -Alias @(
    'dokd-init'
    'dokd-restore'
    'dokd-new'
    'dokd-build'
);

Export-ModuleMember -Function @(
    'Initialize-DOKDsc'
    'Import-DOKDscNodeConfiguration'
    'Register-DOKDscNode'
    'Invoke-DOKDscBuild'
    'Publish-DOKDscCollection'
    'New-DOKDscCollection'
    'Get-DOKDscCollection'
    'Import-DOKDscWorkspaceSetting'
    'Set-DOKDscWorkspaceOption'
    'Get-DOKDscWorkspaceOption'
    'Add-DOKDscModule'
    'Get-DOKDscModule'
    'Publish-DOKDscModule'
    'Restore-DOKDscModule'
);

# EOM
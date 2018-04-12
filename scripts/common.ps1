#
# DOK for DSC common script
#

function CreatePath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String]$Path,

        [Switch]$Clean = $False
    )

    process {

        # If the directory does not exist, force the creation of the path
        if (!(Test-Path -Path $Path)) {
            Write-Verbose -Message "[CreatePath]`t-- Creating path: $Path";

            New-Item -Path $Path -ItemType Directory -Force | Out-Null;
        } else {
            Write-Verbose -Message "[CreatePath]`t-- Path already exists: $Path";

            if ($Clean) {
                 Write-Verbose -Message "[CreatePath]`t-- Cleaning path: $Path";

                 Remove-Item -Path "$Path\" -Force -Recurse -Confirm:$False;

                 New-Item -Path $Path -ItemType Directory -Force | Out-Null;
            }
        }
    }
}

function RunTest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String]$TestGroup,

        [Parameter(Mandatory = $True)]
        [String]$Path,

        [Parameter(Mandatory = $True)]
        [String]$OutputPath,

        [Parameter(Mandatory = $False)]
        [Switch]$CodeCoverage = $False
    )

    begin {
        Write-Verbose -Message "[RunTest]`tBEGIN::";
    }

    process {

        $currentPath = $PWD;

        try {
            #Set-Location -Path "$Path\$TestGroup.Tests" -ErrorAction Stop;

            Write-Verbose -Message "[RunTest]`t-- Running tests: $Path\$TestGroup.Tests";

            # Run Pester tests
            $pesterParams = @{ OutputFile = "$OutputPath\$TestGroup.xml"; OutputFormat = 'NUnitXml'; PesterOption = @{ IncludeVSCodeMarker = $True }; };

            if ($CodeCoverage) {
                $pesterParams.Add('CodeCoverage', "$Path\..\src\$TestGroup\*.psm1");
            }

            Invoke-Pester @pesterParams;

        } finally {
            # Set-Location -Path $currentPath;
        }

    }

    end {
        Write-Verbose -Message "[RunTest]`tEND::";
    }
}

function BuildModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String]$Module,

        [Parameter(Mandatory = $True)]
        [String]$Path,

        [Parameter(Mandatory = $True)]
        [String]$OutputPath
    )

    begin {
        Write-Verbose -Message "[BuildModule] BEGIN::";
    }

    process {

        if (Test-Path -Path ("$OutputPath\$Module")) {
            Remove-Item -Path "$OutputPath\$Module" -Recurse -Force;
        }

        $sourcePath = Join-Path -Path $Path -ChildPath $Module;
        $destinationPath = Join-Path -Path $OutputPath -ChildPath $Module;

        if ($Null -ne (Get-ChildItem -Path $sourcePath -Filter '*.csproj')) {

            Write-Verbose -Message "[BuildModule] -- Building .NET modules";

            # Restore packages
            DotNetRestore -Path $sourcePath;
            
            # Build and publish
            DotNetPublish -Path $sourcePath;
        }

        Write-Verbose -Message "[BuildModule] -- Copying output to: $destinationPath";

        Get-ChildItem -Path $sourcePath -Recurse | Where-Object -FilterScript {
            ($_.FullName -notmatch '(\.(cs|csproj)|(\\|\/)obj)')
        } | ForEach-Object -Process {
            $filePath = $_.FullName.Replace($sourcePath, $destinationPath);

            Copy-Item -Path $_.FullName -Destination $filePath -Force;
        };

        # Copy-Item -Path $sourcePath -Destination $OutputPath -Recurse -Force;

    }

    end {
        Write-Verbose -Message "[BuildModule] END::";
    }
}

function DotNetRestore {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {

        Write-Verbose -Message "[DotNetRestore] -- Restoring .NET dependencies to: $Path";

        dotnet restore $Path;
    }
}

function DotNetPublish {
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {

        $projectFiles = Get-ChildItem -Path $Path -Filter '*.csproj';

        foreach ($p in $projectFiles) {
            $frameworks = GetProjectFramework -Path $p.FullName -Verbose:$VerbosePreference;

            foreach ($f in $frameworks) {
                dotnet publish -f $f $p.FullName;
            }
        }
    }
}

function GetProjectFramework {

    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path
    )

    process {
        Write-Verbose -Message "[GetProjectFramework] -- Checking .NET framework support for: $Path";

        $csProject = [Xml](Get-Content -Path $Path);

        $frameworks = $csProject.Project.PropertyGroup.TargetFrameworks;

        foreach ($f in $frameworks) {
            $f -Split ';';
        }
    }
}

function PackageModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String]$Module,

        [Parameter(Mandatory = $True)]
        [String]$Path,

        [Parameter(Mandatory = $True)]
        [String]$OutputPath
    )

    begin {
        Write-Verbose -Message "[PackageModule] BEGIN::";
    }

    process {

        Write-Verbose -Message "[PackageModule] -- Packaging module: $Module";

        $targetFile = "$OutputPath\$Module.zip";

        Compress-Archive -DestinationPath $targetFile -Path "$Path\$Module" -Force;

        Write-Verbose -Message "[PackageModule] -- Saved module to: $targetFile";
    }

    end {
        Write-Verbose -Message "[PackageModule] END::";
    }
}

function PublishAzureAutomationModule {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String]$Module,

        [Parameter(Mandatory = $True)]
        [String]$AutomationAccount,

        [Parameter(Mandatory = $True)]
        [String]$ResourceGroupName
    )

    process {
        # New-AzureRmAutomationModule -AutomationAccountName $AutomationAccount -ResourceGroupName $ResourceGroupName -Name $m -ContentLink $uri;
    }
}

function FindConfiguration {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Path,

        [Parameter(Mandatory = $True)]
        [String[]]$Include,

        [Parameter(Mandatory = $False)]
        [String]$Suffix = '.Config'
    )

    begin {
        Write-Verbose -Message "[FindConfiguration] BEGIN::";
    }

    process {
        # Look for configuration source files in the include paths
        $result = $Include | ForEach-Object `
        -Process {
            $includeItem = $_;

            Write-Verbose -Message "[FindConfiguration] -- Finding configuration files within include: $includeItem";

            # Get each configuration source file in this include path
            Get-ChildItem -Path "$Path\$includeItem\" -Recurse -Filter ([String]::Concat('*', $Suffix, '.ps1')) | ForEach-Object `
            -Process {
                $configItemPath = $_.FullName;

                Write-Verbose -Message "[FindConfiguration] -- Found configuration: $configItemPath";

                # Emit the path back to the pipeline
                $configItemPath;
            };
        };

        $result;
    }

    end {
        Write-Verbose -Message "[FindConfiguration] END::";
    }
}

function SendAppveyorTestResult {
    
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $True)]
            [String]$Uri,
    
            [Parameter(Mandatory = $True)]
            [String]$Path,
    
            [Parameter(Mandatory = $False)]
            [String]$Include = '*'
        )
    
        begin {
            Write-Verbose -Message "[SendAppveyorTestResult] BEGIN::";
        }
    
        process {
    
            try {
                $webClient = New-Object -TypeName 'System.Net.WebClient';
    
                foreach ($resultFile in (Get-ChildItem -Path $Path -Filter $Include -File -Recurse)) {
    
                    Write-Verbose -Message "[SendAppveyorTestResult] -- Uploading file: $($resultFile.FullName)";
    
                    $webClient.UploadFile($Uri, "$($resultFile.FullName)");
                }
            }
            catch {
                throw $_.Exception;
            }
            finally {
                $webClient = $Null;
            }
        }
    
        end {
            Write-Verbose -Message "[SendAppveyorTestResult] END::";
        }
    }
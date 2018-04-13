
using System;
using System.ComponentModel;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System.IO;

namespace DevOpsKitDsc.Workspace
{
    public enum ConfigurationOptionTarget : byte
    {
        // Build for deployment to a pull server
        FileSystem = 0,

        // Build for use within Azure Automation Service
        AzureAutomationService = 1,

        // Build for use directly within ARM templates
        AzureDscExtension = 2
    }

    public enum CollectionBuildMode : byte
    {
        // Build changed configurations
        Incremental = 1,

        // Always build configuration
        Full = 2
    }

    [JsonObject()]
    public sealed class CollectionOption
    {
        [JsonProperty(PropertyName = "target", DefaultValueHandling = DefaultValueHandling.Ignore)]
        public ConfigurationOptionTarget Target;

        [JsonProperty(PropertyName = "replaceNodeData", DefaultValueHandling = DefaultValueHandling.Ignore)]
        public bool ReplaceNodeData;

        [JsonProperty(PropertyName = "buildMode", DefaultValueHandling = DefaultValueHandling.Ignore)]
        public Nullable<CollectionBuildMode> BuildMode;

        [JsonProperty(PropertyName = "signaturePath", DefaultValueHandling = DefaultValueHandling.Ignore)]
        public string SignaturePath;

        [JsonProperty(PropertyName = "signatureSasToken", DefaultValueHandling = DefaultValueHandling.Ignore)]
        public string SignatureSasToken;

        public CollectionOption()
        {
            // Set defaults
            Target = ConfigurationOptionTarget.FileSystem;
            ReplaceNodeData = false;
        }

        public static implicit operator CollectionOption(Hashtable value)
        {
            var result = new CollectionOption();

            // Bind hashtable options to new CollectionOption object

            if (value.ContainsKey("Target")) {
                result.Target = (ConfigurationOptionTarget)value["Target"];
            }

            if (value.ContainsKey("ReplaceNodeData")) {
                result.ReplaceNodeData = (bool)value["ReplaceNodeData"];
            }

            if (value.ContainsKey("BuildMode")) {
                result.BuildMode = (CollectionBuildMode)value["BuildMode"];
            }

            if (value.ContainsKey("SignaturePath")) {
                result.SignaturePath = (string)value["SignaturePath"];
            }

            if (value.ContainsKey("SignatureSasToken")) {
                result.SignatureSasToken = (string)value["SignatureSasToken"];
            }

            return result;
        }
    }

    [JsonObject()]
    public sealed class DocumentationOption
    {
        // A path to the documentation template
        [JsonProperty(PropertyName = "path")]
        public string Path;

        // A specific document template name to use
        [JsonProperty(PropertyName = "name")]
        public string Name;
    }

    [JsonObject()]
    public sealed class Collection
    {
        [JsonProperty(PropertyName = "name", Required = Required.Always)]
        public string Name;

        [JsonProperty(PropertyName = "options", DefaultValueHandling = DefaultValueHandling.Ignore)]
        public CollectionOption Options;

        [JsonProperty(PropertyName = "path", Required = Required.Always)]
        public string Path;

        [JsonProperty(PropertyName = "configurationName", DefaultValueHandling = DefaultValueHandling.Ignore)]
        public string ConfigurationName;

        [JsonProperty(PropertyName = "nodes", DefaultValueHandling = DefaultValueHandling.Ignore)]
        public List<string> Nodes;

        [JsonProperty(PropertyName = "data", DefaultValueHandling = DefaultValueHandling.Ignore)]
        public Hashtable Data;

        [JsonProperty(PropertyName = "docs", DefaultValueHandling = DefaultValueHandling.Ignore)]
        public DocumentationOption Docs;

        public Collection()
        {
            // Set defaults
            // Tags = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        }
    }

    [JsonObject()]
    public sealed class WorkspaceOption
    {
        [JsonProperty(PropertyName = "outputPath", DefaultValueHandling = DefaultValueHandling.Ignore)]
        [DefaultValue(".\\build")]
        public string OutputPath;

        [JsonProperty(PropertyName = "nodePath", DefaultValueHandling = DefaultValueHandling.Ignore)]
        [DefaultValue(".\\nodes")]
        public string NodePath;

        [JsonProperty(PropertyName = "modulePath", DefaultValueHandling = DefaultValueHandling.Ignore)]
        [DefaultValue(".\\modules")]
        public string ModulePath;

        public WorkspaceOption()
        {
            // Set option defaults
            OutputPath = ".\\build";
            NodePath = ".\\nodes";
            ModulePath = ".\\modules";
        }
    }

    [JsonObject()]
    public sealed class Module
    {
        /// <summary>
        /// The name of a PowerShell module.
        /// </summary>
        [JsonProperty(PropertyName = "name", Required = Newtonsoft.Json.Required.Always)]
        public string ModuleName;

        /// <summary>
        /// A specific version of the module.
        /// </summary>
        [JsonProperty(PropertyName = "version", Required = Newtonsoft.Json.Required.Always)]
        public string ModuleVersion;

        [JsonProperty(PropertyName = "repository", DefaultValueHandling = DefaultValueHandling.Ignore)]
        public string Repository;

        [JsonProperty(PropertyName = "path", DefaultValueHandling = DefaultValueHandling.Ignore)]
        public string Path;

        [JsonProperty(PropertyName = "type", DefaultValueHandling = DefaultValueHandling.Ignore)]
        public string Type;

        public Module()
        {
            Repository = null;
            Path = null;
            Type = null;
        }

        public override string ToString()
        {
            return string.Concat(ModuleName, ' ', ModuleVersion);
        }
    }

    [JsonObject()]
    public sealed class WorkspaceSetting
    {
        [JsonProperty(PropertyName = "version", Order = 0)]
        public string Version;

        [JsonProperty(PropertyName = "options", Order = 1)]
        public WorkspaceOption Options;

        [JsonProperty(PropertyName = "modules", Order = 3)]
        public List<Module> Modules;
        
        [JsonProperty(PropertyName = "collections", Order = 2)]
        public List<Collection> Collections;
        
        public WorkspaceSetting()
        {
            // Set defaults
            Version = "0.1.0";
            Options = new WorkspaceOption();
            Modules = new List<Module>();
            Collections = new List<Collection>();
        }
    }

    public static class WorkspaceHelper
    {
        public static WorkspaceSetting LoadFrom(string path)
        {
            if (System.IO.File.Exists(path))
            {
                using (var stream = new FileStream(path, FileMode.Open))
                {
                    using (var reader = new System.IO.StreamReader(stream))
                    {
                        var jsonSetting = new JsonSerializerSettings();
                        jsonSetting.Formatting = Formatting.Indented;

                        return JsonConvert.DeserializeObject<WorkspaceSetting>(reader.ReadToEnd(), jsonSetting);
                    }
                }
            }
            else
            {
                return new WorkspaceSetting();
            }
        }

        public static WorkspaceSetting LoadDefault()
        {
            return new WorkspaceSetting();
        }

        public static void SaveTo(string path, WorkspaceSetting setting)
        {
            using (var stream = new FileStream(path, FileMode.Create))
            {
                using (var writer = new System.IO.StreamWriter(stream))
                {
                    var jsonSetting = new JsonSerializerSettings();
                    jsonSetting.Formatting = Formatting.Indented;

                    writer.Write(JsonConvert.SerializeObject(setting, jsonSetting));
                }
            }
        }
    }
}

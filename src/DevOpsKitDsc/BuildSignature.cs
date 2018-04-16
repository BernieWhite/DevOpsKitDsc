using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System.Collections;
using System.IO;
using System.Security.Cryptography;

namespace DevOpsKitDsc.Build
{
    [JsonObject()]
    public sealed class FileIntegrity
    {
        [JsonProperty(PropertyName = "path")]
        public string Path;
    }

    /// <summary>
    /// A signature that tracks the source files that were previous used to build a DSC configuration so that DevOpsKit for DSC can determine when these files are changed.
    /// </summary>
    [JsonObject()]
    public sealed class BuildSignature
    {
        [JsonProperty(PropertyName = "instanceName")]
        public string InstanceName;

        [JsonProperty(PropertyName = "collectionName")]
        public string CollectionName;

        [JsonProperty(PropertyName = "node")]
        public Hashtable Node;

        [JsonProperty(PropertyName = "path")]
        public string Path;

        [JsonProperty(PropertyName = "docs")]
        public FileIntegrity Docs;

        [JsonProperty(PropertyName = "buildIntegrity")]
        public string BuildIntegrity;

        public void Update()
        {
            BuildIntegrity = SignatureHelper.UpdateIntegrity(this);
        }
    }

    public static class SignatureHelper
    {
        public static BuildSignature LoadFrom(string path)
        {
            if (System.IO.File.Exists(path))
            {
                using (var stream = new FileStream(path, FileMode.Open))
                {
                    using (var reader = new System.IO.StreamReader(stream))
                    {
                        var jsonSetting = new JsonSerializerSettings();
                        jsonSetting.Formatting = Formatting.Indented;

                        return JsonConvert.DeserializeObject<BuildSignature>(reader.ReadToEnd(), jsonSetting);
                    }
                }
            }
            else
            {
                return new BuildSignature();
            }
        }

        public static void SaveTo(string path, BuildSignature signature)
        {
            using (var stream = new FileStream(path, FileMode.Create))
            {
                using (var writer = new System.IO.StreamWriter(stream))
                {
                    var jsonSetting = new JsonSerializerSettings();
                    jsonSetting.Formatting = Formatting.Indented;

                    writer.Write(JsonConvert.SerializeObject(signature, jsonSetting));
                }
            }
        }

        public static string UpdateIntegrity(BuildSignature signature)
        {
            
            return ComputeBuildIntegrity(
                signature.InstanceName,
                GetFileIntegrity(signature.Path),
                GetHashtableIntegrity(signature.Node)
            );
        }

        private static string ComputeBuildIntegrity(params string[] hash)
        {
            using (var alg = SHA256.Create())
            {
                return GetHashString(alg.ComputeHash(System.Text.Encoding.UTF8.GetBytes(string.Concat(hash))));
            }
        }

        private static string GetFileIntegrity(string path)
        {
            using (var alg = SHA256.Create())
            {
                using (var stream = new FileStream(path, FileMode.Open))
                {
                    return GetHashString(alg.ComputeHash(stream));
                }
            }
        }

        private static string GetHashtableIntegrity(Hashtable value)
        {
            using (var alg = SHA256.Create())
            {
                return GetHashString(
                    alg.ComputeHash(
                        System.Text.Encoding.UTF8.GetBytes(
                            JsonConvert.SerializeObject(value)
                        )
                    )
                );
            }
        }

        private static string GetHashString(byte[] value)
        {
            System.Text.StringBuilder hash = new System.Text.StringBuilder();

            foreach (byte b in value)
            {
                hash.Append(b.ToString("X2"));
            }

            return hash.ToString();
        }
    }
}
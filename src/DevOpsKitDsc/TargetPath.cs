using Newtonsoft.Json;

namespace DevOpsKitDsc
{
    public sealed class TargetPath
    {
        [JsonProperty(PropertyName = "path", DefaultValueHandling = DefaultValueHandling.Ignore)]
        public string Path { get; set; }

        [JsonProperty(PropertyName = "sasToken", DefaultValueHandling = DefaultValueHandling.Ignore)]
        public string SasToken { get; set; }

        public static implicit operator TargetPath(string value)
        {
            return new TargetPath {
                Path = value
            };
        }
    }
}

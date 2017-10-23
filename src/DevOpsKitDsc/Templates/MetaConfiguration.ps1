

[DscLocalConfigurationManager()]
configuration MetaConfiguration {

    Node $AllNodes.NodeName {

        Settings {
            # Set refresh mode, default is Push
            RefreshMode = 'Push'

            # Set configuration mode
            # Default: ApplyAndMonitor
            ConfigurationMode = 'ApplyAndMonitor' 

            # Enabled reboots as required, only applies when configured is applied
            # Default: $False
            RebootNodeIfNeeded = $True

            AllowModuleOverwrite = $False

            ConfigurationModeFrequencyMins = 30;
            
            RefreshFrequencyMins = 30;

            # Set the certificate thumbprint to use for credential decryption
            CertificateId = $Node.Thumbprint;
        }

    }
}
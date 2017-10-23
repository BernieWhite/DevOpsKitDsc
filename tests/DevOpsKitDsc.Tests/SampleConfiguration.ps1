

configuration SampleConfiguration {

    Import-DscResource -ModuleName PSDesiredStateConfiguration;
    
    node $AllNodes.NodeName {

        File FileResorce {
            Ensure = 'Present'
            DestinationPath = 'C:\FileResource'
            Type = 'File'
            Contents = 'SampleConfigration'
        }
    }
}
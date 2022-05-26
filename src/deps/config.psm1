class Configuration {
    #
    # Summary:
    # 		The default content of the configuration file.
    #	 
    hidden static [object] $Content = [ordered]@{
        Version = [ordered]@{ 
            Current  = '';
            Previous = ''; 
        }
    };

    #
    # Summary:
    # 		The path of the configuration file.
    #	 
    static [string] $Path = (Join-Path $pwd.Path 'build.json');

    #
    # Summary:
    # 		-
    # 
    # Returns:
    #		The value of the property 'Version'.
    #
    static [object] GetVersion() {
        try {
            $data = Get-Content ([Configuration]::Path) -Raw -ErrorAction Stop;
            $json = $data | ConvertFrom-Json;

            return ($json).Version;
        } catch {
            throw $_;
        }
    }

    #
    # Summary:
    # 		-
    # 
    # Parameters:
    # 	Current
    #		The value to set as "current".
    #	Previous
    # 		The value to set as "previous".
    #
    static [void] UpdateVersion($Current, $Previous) {
        $Object = [Configuration]::Content;
        $Object.Version = [ordered]@{ 
            Current  = $Current; 
            Previous = $Previous;
        };
        
        ConvertTo-Json -InputObject $Object | Out-File ([Configuration]::Path) -NoNewLine -ErrorAction Stop;
    }
}
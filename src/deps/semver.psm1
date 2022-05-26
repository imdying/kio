class SemVer {
    [UInt32] $Major;
    [UInt32] $Minor;
    [UInt32] $Patch;
    [string] $PreRelease;
    [UInt32] $Build;
    [UInt32] $Revision;
    [bool] $IsPreRelease;

    #
    # Summary:
    # 		-
    # 
    # Parameters:
    #  	Value
    #		A string representing the version number.
    #
    static [SemVer] Parse($value) {
        $Version = [SemVer]::new();
        $Validate = $value -match '^(?<major>\d+)(\.(?<minor>\d+))?(\.(?<patch>\d+))?(\-(?<pre>[0-9A-Za-z\-\.]+))?(\+(?<build>\d+))?$';
        
        if (!$Validate) {
            throw 'Invalid semantic version number';
        }
        
        $Version.Major = [UInt32] $matches['major'];
        $Version.Minor = [UInt32] $matches['minor'] ?? 0;
        $Version.Patch = [UInt32] $matches['patch'] ?? 0;

        if ($null -ne $matches['pre']) {
            $Validate = $matches['pre'] -match '^(?<pre>\w+)(\.(?<build>\d+))?(\.(?<revision>\d+))?$';

            if (!$Validate) {
                throw 'Invalid pre-release at SemVer.Parse()';
            }

            $Version.IsPreRelease = $true;
            $Version.PreRelease = $matches['pre'];
            $Version.Revision = $matches['Revision'] ?? 0;
            $Version.Build = $matches['build'] ?? 0;
        }

        return $Version;
    }

    [string] ToString() {
        $Release = [string]::Format('{0}.{1}.{2}', $this.Major, $this.Minor, $this.Patch);
        $Result = !$this.IsPreRelease ? $Release : [string]::Format('{0}-{1}.{2}.{3}', $Release, $this.PreRelease, $this.Build, $this.Revision);
        return $Result;
    }

    [void] PreReleasify($id, $build, $rev) {
        if ([string]::IsNullOrEmpty($id) -or 
            [string]::IsNullOrEmpty($build) -or
            [string]::IsNullOrEmpty($rev)) {
            throw 'Empty values at PreReleasify()';
        }

        $this.Major++;
        $this.Minor = 0;
        $this.Patch = 0;
        $this.PreRelease = $id;
        $this.IsPreRelease = $true;
        $this.Build = $build;
        $this.Revision = $rev;
    }
}
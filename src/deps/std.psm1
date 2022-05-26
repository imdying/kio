using module '.\config.psm1';
using module '.\semver.psm1';
using module '.\common.psm1';

$ErrorActionPreference = 'Stop';

<#
    .SYNOPSIS
        -

    .DESCRIPTION
        Returns an object that contains version number, prefix and suffix of the current version.
#>
function GetVersion {
    $Version = [Configuration]::GetVersion().Current;
    $ParsedVersion = [SemVer]::Parse($Version);

    return @{
        Prefix  = [string]::Format('{0}.{1}.{2}', $ParsedVersion.Major, $ParsedVersion.Minor, $ParsedVersion.Patch);
        Suffix  = $ParsedVersion.IsPreRelease ? [string]::Format('{0}.{1}.{2}', $ParsedVersion.PreRelease, $ParsedVersion.Build, $ParsedVersion.Revision) : $null;
        Version = $Version;
    };
}

<#
    .SYNOPSIS
        -

    .DESCRIPTION
        Update the values of the property 'Version'.
#>
function UpdateVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Current,
        [string] $Previous
    )

    [Configuration]::UpdateVersion($Current, $Previous);
}

<#
    .SYNOPSIS
        Versioning control for apps.

    .DESCRIPTION
        After execution, the version number from config file should've been updated. Retrieve the # using 'GetVersion'.
#>
function PromptVersionControl {
    [CmdletBinding()]
    param (
        [bool]$HandleRelease = $true
    )

    $Version = [Configuration]::GetVersion().Current;
    $ParsedVersion = [SemVer]::Parse($Version);

    Write-Host "Current version: $Version" -ForegroundColor Magenta;
    $Options = (!$ParsedVersion.IsPreRelease ? 'Major', 'Minor', 'Patch', 'Pre-Release' : 'Major (Release)', 'Pre-Release');
    $Selection = AskUserInput 'Select a version to increment. (Leave blank for auto-incrementing)' -Options $Options;
    
    switch ($ParsedVersion.IsPreRelease) {
        $true {  
            switch ($Selection) {
                # Auto-incrementing
                0 {
                    $ParsedVersion.Revision++;
                }
        
                # Major
                1 {
                    $ParsedVersion.IsPreRelease = $false;
                }
        
                # Pre-Release
                2 {
                    $Index = 0;
                    $_Options = 'alpha', 'beta', 'rc';
                    $Options = 'Alpha', 'Beta', 'Release Candidate';

                    for ($i = 0; $i -lt $_Options.Length; $i++) {
                        $option = $_Options[$i];
                        
                        if ($option -like $ParsedVersion.PreRelease) {
                            $Index = ($i + 1);
                            $Options[$i] += ' (Current)';
                            break;
                        }
                    }

                    $Selection = AskUserInput 'Select the pre-release version to increment to.' -Options $Options;

                    # Current was selected.
                    if ($Selection -eq $Index) {
                        $Options = 'Build', 'Revision (Default)';
                        $Selection = AskUserInput 'Select a version to increment.' -Options $Options;

                        switch ($Selection) {
                            0 {
                                $ParsedVersion.Revision++;
                            }

                            1 {
                                $ParsedVersion.Build++;
                            }

                            2 {
                                $ParsedVersion.Revision++;
                            }

                            Default {
                                throw 'Invalid option';
                            }
                        }

                        break;
                    }

                    # Not current, but a newer or old
                    switch ($Selection) {
                        # alpha
                        1 {
                            throw 'Cannot downgrade version.';
                        }

                        # beta
                        2 {
                            if ($ParsedVersion.PreRelease -eq 'rc') {
                                throw 'Cannot downgrade version.';
                            }
                            
                            $ParsedVersion.PreRelease = 'beta';
                            $ParsedVersion.Build = 1;
                            $ParsedVersion.Revision = 0;
                        }

                        # rc
                        3 {
                            $ParsedVersion.PreRelease = 'rc';
                            $ParsedVersion.Build = 1;
                            $ParsedVersion.Revision = 0;
                        }

                        Default {
                            throw 'Invalid option';
                        }
                    }
                }

                Default {
                    throw 'Invalid option.';
                }
            }
        }

        $false {
            switch ($Selection) {
                # Auto-incrementing
                0 {
                    $ParsedVersion.Patch++;
                }
        
                # Major
                1 {
                    $ParsedVersion.Major++;
                    $ParsedVersion.Minor = 0;
                    $ParsedVersion.Patch = 0;
                }
        
                # Minor
                2 {
                    $ParsedVersion.Minor++;
                    $ParsedVersion.Patch = 0;
                }
        
                # Patch
                3 {
                    $ParsedVersion.Patch++;
                }
        
                # Pre-Release
                4 {
                    $Options = 'Alpha', 'Beta', 'Release Candidate';
                    $Selection = AskUserInput 'Select the pre-release version to increment to.' -Options $Options;

                    switch ($Selection) {
                        # alpha
                        1 {
                            $ParsedVersion.PreReleasify('alpha', 1, 0);
                        }
        
                        # beta
                        2 {
                            $ParsedVersion.PreReleasify('beta', 1, 0);
                        }
        
                        # rc
                        3 {
                            $ParsedVersion.PreReleasify('rc', 1, 0);
                        }
        
                        Default {
                            throw 'Invalid option';                        
                        }
                    }
                }
        
                Default {
                    throw 'Invalid option.';
                }
            }
        }
    }

    $Current = $ParsedVersion.ToString();
    $Previous = $Version;

    Write-Host ([string]::Format("Upgrading from '{0}' to '{1}'", $Previous, $Current)) -ForegroundColor Magenta;

    if ($HandleRelease) {
        [Configuration]::UpdateVersion($Current, $Previous);
    }
}
using module '..\deps\common.psm1';
using module '..\deps\config.psm1';

$ErrorActionPreference = 'Stop';

# Help
if ($args.Length -eq 0) {
    $args += 'Help';
}

# Debug last error by calling '$Error[0].ScriptStackTrace'
# or 'Get-Error'
switch ($args[0]) {
    # Aliases
    '--b' {
         $_ = 'Build';
    }

    '--v' {
        $_ = 'Version';
    }

    # Commands
    'Help' {
        $Version = (Get-Content -Raw (Join-Path $PSScriptRoot 'app.json') | ConvertFrom-Json).Version;

        'Kio ' + $Version
        'Copyright (C) 2022 Blank.'
        "`nCommands:"
        '  New           Create a template.'
        '  Build, --b    Execute the build script.'
        '  Rollback      Rollback the current version number to the prior value. (build.json)'
        '  Version, --v  Display the current version of the build script.'
        "`nFor more information, refer to https://github.com/imdying/kio"
    }

    'Build' {
        Import-Module (Join-Path $pwd.Path 'build.psm1') -Force -Scope Local;

        # Key    The function name.
        # Value  is what gets displayed when outputing.
        $BuildType  = [ordered]@{ 
            Debug   = 'Debug';
            Release = 'Release';
            Publish = 'Publish';
        }

        $GetBuilds = {
            $Array = New-Object System.Collections.Generic.List[System.String];

            for ($i = 0; $i -lt $BuildType.Count; $i++) {
                $Name  = $BuildType[$i];                                                        # The value of the $BuildType.Key.
                $Method = $BuildType.Keys | Where-Object { $BuildType[$_] -eq "$Name" };        # The $BuildType.Key.

                if ([bool](Get-Command "$Method" -errorAction SilentlyContinue)) {
                    $Array.Add($Name);
                    continue;
                }

                $BuildType.RemoveAt($i);
                $i--;
            }

            return $Array.ToArray();
        }.Invoke();

        if ($GetBuilds.Count -lt 1) {
            PrintError 'No build-methods were found in the build.';
        }

        # Handles input if it is passed thru args.
        $InputFromParams = {
            param ($p1)

            if ($null -eq $p1) {
                return 0;
            }
            
            for ($i = 0; $i -lt $GetBuilds.Count; $i++) {
                $bt = $GetBuilds[$i];                                               #! Using $BuildType Value instead of its Key.
                if ($bt -eq $p1) {
                    return $i + 1;
                }
            }

            PrintError 'Not a valid input.'
        }
        
        $Option = AskUserInput 'Target a build by specifying the numeric value of the options below.' -Options $GetBuilds -Select $InputFromParams.Invoke($args[1])[0];

        if ($Option -gt $GetBuilds.Count -or $Option -lt 1) {
            PrintError 'Specified value doesn''t correlate with the available options.';
        }
        
        # Executing the build.
        $Name  = $GetBuilds[$Option - 1];                                           # Value.
        $Build = $BuildType.Keys | Where-Object { $BuildType[$_] -eq "$Name" };     # Key.

        Write-Host "Targeting '$Name'" -ForegroundColor Magenta;
        & $Build;
    }

    'New' {
        $Tmpls = Join-Path $PSScriptRoot 'etc' 'templates';
        $Files = (Join-Path $Tmpls 'build.json'), (Join-Path $Tmpls 'build.psm1');

        for ($i = 0; $i -lt $Files.Length; $i++) {
            $File = $Files[$i];
            $FileName = [System.IO.Path]::GetFileName($File);
            $Dest = Join-Path $pwd.Path $FileName;

            if ([System.IO.File]::Exists($Dest)) {
                throw "File already exists at '$Dest' "
            }

            [System.IO.File]::Copy($File, $Dest);
        }

        'Template generated.'
    }

    'Version' {
        $Version = [Configuration]::GetVersion();
        $Current = $Version.Current;

        Write-Host $Current -ForegroundColor Yellow;
    }

    'Rollback' {
        $Version = [Configuration]::GetVersion();
        $Current = $Version.Current;
        $Previous = $Version.Previous;

        if ([string]::IsNullOrEmpty($Previous)) {
            throw 'No prior version found to rollback.';
        }
        
        Write-Host 'Rolling back from ' -NoNewline;
        Write-Host "'$Current'" -ForegroundColor Yellow -NoNewline;
        Write-Host ' to ' -NoNewline;
        Write-Host "'$Previous'" -ForegroundColor Yellow;
        
        [Configuration]::UpdateVersion($Previous, '');
    }

    Default {
        throw 'Invalid command.';
    }
}
using module '.\deps\config.psm1';
using module '.\deps\common.psm1';

$ErrorActionPreference = 'Stop';

# Help
if ($args.Length -eq 0) {
    $Version = (Get-Content -Raw (Join-Path $PSScriptRoot 'app.json') | ConvertFrom-Json).Version;

    'Kio ' + $Version
    "`nCommands:"
    '  New       Create a template.'
    '  Run       Execute the build script.'
    '  Rollback  Rollback the current version number to the prior value. (build.json)'
    '  Version   Display the current version of the build script.'
    "`nFor more information, refer to https://github.com/imdying/kio"
    return;
}

# Debug last error by calling '$Error[0].ScriptStackTrace'
# or 'Get-Error'
switch ($args[0]) {
    Run {
        Import-Module -Force -Scope Local (Join-Path $pwd.Path 'build.psm1');

        enum BuildType {
            Debug = 1
            Release
            Publish
        }

        # If the input is passed through args, $Option and this are basically the same.
        $Select = $args.Length -gt 1 ? ([Enum]::ToObject([BuildType], $args[1])) : 0;
        $Option = AskUserInput 'Target a build by specifying the numeric value of the options below.' -Options 'Debug', 'Release', 'Publish' -Select $Select;

        # The length of BuildType.
        $EnumSize = [Enum]::GetValues([BuildType]).Length;

        # 
        if ($Option -gt $EnumSize -or $Option -lt 1) {
            throw 'Specified value doesn''t correlate with the available options.';
        }
        
        # Executing the build.
        for ($i = 1; $i -lt $EnumSize + 1; $i++) {
            if ($Option -eq [Enum]::ToObject([BuildType], $i)) {
                $build = [BuildType]$i;

                # Targeting build: $i
                Write-Host "Targeting '$build'" -ForegroundColor Magenta;

                # Only works if the function name matches
                & $build;

                return;
            }
        }
    }

    New {
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

    Version {
        $Version = [Configuration]::GetVersion();
        $Current = $Version.Current;

        Write-Host $Current -ForegroundColor Yellow;
    }

    Rollback {
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
$root = $PSScriptRoot;
$deps = Join-Path $root 'deps';
$app  = Join-Path $root 'bin';
$ErrorActionPreference = 'Stop';

<#
    .SYNOPSIS
        -

    .DESCRIPTION
        An over-engineered build script with semantic versioning support.

    .LINK
        https://github.com/imdying/kio/
#>
function Kio {
    param($p1, $p2)

    $script = Join-Path $app 'app.ps1';
    $script:args = $null;

    foreach ($key in $PSBoundParameters.keys) {
        $Script:args += $PSBoundParameters["$key"];
    }

    if ($script:args.Length -eq 0) {
        & $script;
    } else {
        # https://stackoverflow.com/a/45772517
        & $script @script:args;
    }
}

<#
    .SYNOPSIS
        -

    .DESCRIPTION
        Import Kio's dependencies in the current session.

    .LINK
        https://github.com/imdying/kio/
#>
function ImportDependencies {
    Import-Module -Global -Force (Join-Path $deps 'std.psm1');
}

Export-ModuleMember -Function *
<#
    Tested on PowerShell 7.2.3
    For more information, refer to https://github.com/imdying/kio
#>
ImportDependencies;

function Debug {
    # Todo
}

function Release {
    # Todo
}

function Publish {
    PromptVersionControl;
    $Version = GetVersion;

    # App versioning
    ConvertTo-Json -InputObject @{Version = $Version.Version} | Out-File '.\src\app.json';

    # Packing
    $Issc = Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6' 'ISCC.exe'; 
    & $Issc '.\build.iss' "/DApplicationVersion=$($Version.Prefix)";
}
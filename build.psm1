# Tested on PowerShell 7.2
# For more information, refer to https://github.com/imdying/kio

ImportDependencies;

function Publish {
    $Version = PromptVersionControl;
    $Compile = Join-Path "${env:ProgramFiles(x86)}" 'Inno Setup 6' 'ISCC.exe';

    ConvertTo-Json -InputObject @{ Version = $Version.Absolute } | Out-File '.\src\bin\app.json';   # App versioning
    & $Compile '.\build.iss' "/DApplicationVersion=$($Version.Prefix)";                             # Packing
}
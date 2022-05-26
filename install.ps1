#Requires -Version 4.0
#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop';

# Download
$d_url = 'https://github.com/imdying/Kio/releases/latest/download/Kio.exe';
$f_url = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName() + '.exe');

Invoke-WebRequest $d_url -OutFile $f_url;

# Launch the installer and del it after it's exited.
Start-Process $f_url -Wait;
Remove-Item -Force $f_url;

# Profile handling
$x64 = Join-Path $env:ProgramW6432 'Kio' 'export.psm1';
$x86 = Join-Path ${env:ProgramFiles(x86)} 'Kio' 'export.psm1';
$globalProfile = $PROFILE.AllUsersAllHosts;

# Profile already exists or kio can't be found.
if ([System.IO.File]::Exists($globalProfile) -or 
    ![System.IO.File]::Exists($x86) -or 
    ![System.IO.File]::Exists($x64) ) {
    "Append the content below to your global powershell profile.`nTo get the path of the global profile, call the variable '`$PROFILE.AllUsersAllHosts'.`n"
    '# Kio.'
    "Import-Module -Global -Force 'KIO_INSTALL_PATH\export.psm1';"
    return;
}

# Create profile
if (![System.IO.File]::Exists($profile)) {
    if ([System.IO.File]::Exists($x64)) {
        "Import-Module -Global -Force '$x64';" > $PROFILE.AllUsersAllHosts;
    } else {
        "Import-Module -Global -Force '$x86';" > $PROFILE.AllUsersAllHosts;
    }
}

Write-Host 'Completed.';
# Kio
An over-engineered build script with semantic versioning support.

## Installation
Download the [latest release](https://github.com/imdying/kio/releases/latest/download/bs_installer.exe) and read the [notice.txt](https://raw.githubusercontent.com/imdying/kio/main/src/notice.txt).

## Getting Started
Once installed, open a powershell console, `cd` into a directory and enter this command to generate a template.

```powershell
kio new
```

Once completed, 2 new files will be created, `build.psm1` and `build.json`. Inside `build.psm1`, there will be 3 functions, each function representing a build type.

```powershell
function Debug {
    ...
}

function Release {
    ...
}

function Publish {
    ...
}
```

### Invoking the version-control input.

```powershell
ImportDependencies;                 # Import 'PromptVersionControl', 'GetVersion'
                                    # and 'UpdateVersion'.

function Publish {
    $Version  = PromptVersionControl;
    
    $Prefix   = $Version.Prefix;    # 2.0.0
    $Suffix   = $Version.Suffix;    # beta.1.0
    $Absolute = $Version.Absolute;  # 2.0.0-beta.1.0

    # compiler build 'myproject.csproj' --version=$Prefix
}
```
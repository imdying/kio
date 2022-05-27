# Kio
An over-engineered build script with semantic versioning support.

## Installation
Download the [latest release](https://github.com/imdying/Kio/releases/latest/download/Kio.exe) and read the [notice.txt](https://raw.githubusercontent.com/imdying/Kio/main/src/notice.txt).

## Getting Started
Once installed, generate a template and open the file `build.psm1`. Inside, there will be 3 functions, each function representing a build type.

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

### Invoking the version control input.

```powershell
# Import 'PromptVersionControl' and other related functions.
ImportDependencies;

function Publish {
    PromptVersionControl;
    $Version = GetVersion;

   # My code
   build.exe 'myproject' --version $Version.Prefix
}
```
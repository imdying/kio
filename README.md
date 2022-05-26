# Kio
An over-engineered build script with semantic versioning support.

## Installation
Download the latest release from [GitHub](https://github.com/imdying/kio/releases/latest), or.
<br/>
<br/>
PowerShell (Windows): 
```powershell
iwr 'https://raw.githubusercontent.com/imdying/kio/main/install.ps1' | iex
```

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
# This imports 'PromptVersionControl' and other related functions.
ImportDependencies;

function Publish {
    PromptVersionControl;
    $Version = GetVersion;

   # My code
   build.exe 'myproject' --version $Version
}
```
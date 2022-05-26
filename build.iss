#define MyAppName "Kio";

#ifndef Version
  #define Version = '1.0.0';
#endif

[Setup]
AppName={#MyAppName}
AppVersion={#ApplicationVersion}
AppPublisher=Blank
AppPublisherURL=https://github.com/imdying
WizardStyle=modern
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName=Programs
Compression=lzma2
SolidCompression=yes
OutputDir=bin
OutputBaseFilename={#MyAppName}
; UninstallDisplayIcon={uninstallexe}
UninstallDisplayName={#MyAppName} -  {#ApplicationVersion}

[Files]
Source: ".\src\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Code]
procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpWelcome then
    WizardForm.Caption := 'Setup - Kio {#ApplicationVersion}';
end;
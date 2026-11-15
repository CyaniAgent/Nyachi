; Nyachi Windows installer — Inno Setup 6 script.
;
; The Release workflow (.github/workflows/release.yml) compiles this after
; `flutter build windows --release`, passing the version from the release
; tag:
;
;   ISCC.exe /DAppVersion=2.1.0-beta.8 /O<repo>\out tool\packaging\windows\nyachi.iss
;
; A local build from the repository root (Inno Setup 6 is preinstalled on
; GitHub's Windows runners; elsewhere install it from jrsoftware.org):
;
;   "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" /DAppVersion=2.1.0-beta.8 tool\packaging\windows\nyachi.iss

#ifndef AppVersion
  ; Local builds without the workflow's /D flag still compile.
  #define AppVersion "0.0.0-dev"
#endif

#define MyAppName "Nyachi"
#define MyAppPublisher "AyaxYuna"
#define MyAppURL "https://github.com/CyaniAgent/Nyachi"
; Relative to this script (tool/packaging/windows), i.e. the repository root
; three levels up.
#define BundleDir "..\..\..\build\windows\x64\runner\Release"

[Setup]
; AppId is fixed for the product's lifetime — Windows keys upgrades and
; uninstall on it. Never change this value.
AppId={{AF0B7549-DEE6-41AE-8DB2-ED17B7E93B4C}
AppName={#MyAppName}
AppVersion={#AppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
; Per-user install: no UAC prompt and no Program Files write access needed,
; which keeps the installer working on locked-down machines.
DefaultDirName={localappdata}\Nyachi
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputBaseFilename=nyachi-{#AppVersion}-windows-x64-setup
SetupIconFile=nyachi.ico
UninstallDisplayIcon={app}\nyachi.exe
UninstallDisplayName={#MyAppName}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; ignoreversion: every build replaces the file regardless of its version
; resource, which is what a per-user app directory wants.
Source: "{#BundleDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\nyachi.exe"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\nyachi.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\nyachi.exe"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent

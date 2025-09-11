// The SourceDir variable is now correctly passed by the Python server via the command line
// and will point to the temporary build directory.

#define MyAppName "Bluck D-ESC"
#define MyAppVersion "1.0"
#define MyAppPublisher "Bluck Security"
#define MyAppURL "https://www.bluck.com/"
#define MyAppExeName "D-ESC.exe"

[Setup]
AppId={{AE0A61F1-998E-4CB9-9870-DBFF70D45D0C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64
DisableProgramGroupPage=yes
OutputBaseFilename=Bluck-Security-Setup
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Dirs]
Name: "{sd}\{#MyAppName}_env"; Attribs: hidden

[Files]
// 1. Copy frontend.exe and rename it to bla.exe using DestName
Source: "{#SourceDir}\flutter_app\frontend.exe"; DestDir: "{app}"; DestName: "D-ESC.exe"; Flags: ignoreversion

// 2. Copy all OTHER files and folders from flutter_app, excluding the original frontend.exe
Source: "{#SourceDir}\flutter_app\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "frontend.exe"

// --- These lines remain the same ---
Source: "{#SourceDir}\scripts\configure_firewall.bat"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "{#SourceDir}\scripts\remove_firewall.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\.env"; DestDir: "{sd}\{#MyAppName}_env"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{tmp}\configure_firewall.bat"; Flags: runhidden waituntilterminated
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "{app}\remove_firewall.bat"; Flags: runhidden waituntilterminated

[UninstallDelete]
Type: filesandordirs; Name: "{sd}\{#MyAppName}_env"
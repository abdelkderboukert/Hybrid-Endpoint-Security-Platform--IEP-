// This variable will be set by our Python server
#define SourceDir "C:\Users\HP\rebo\3LayersUntiVirus\ESB\assets"

#define MyAppName "Bluck D-ESC"
#define MyAppVersion "1.0"
#define MyAppPublisher "Bluck Securty"
#define MyAppURL "https://www.Bluck.com/"
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
// Use the {#SourceDir} variable to find files in the temporary folder
Source: "{#SourceDir}\flutter_app\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceDir}\scripts\configure_firewall.bat"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "{#SourceDir}\scripts\remove_firewall.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\template.env"; DestDir: "{sd}\{#MyAppName}_env"; DestName: ".env"

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
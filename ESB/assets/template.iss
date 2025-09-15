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
Source: "{#SourceDir}\flutter_app\frontend.exe"; DestDir: "{app}"; DestName: "D-ESC.exe"; Flags: ignoreversion
Source: "{#SourceDir}\flutter_app\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "frontend.exe"
Source: "{#SourceDir}\scripts\configure_firewall.bat"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "{#SourceDir}\scripts\remove_firewall.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\.env"; DestDir: "{sd}\{#MyAppName}_env"; Flags: ignoreversion
Source: "C:\Users\HP\rebo\3LayersUntiVirus\ESB\assets\vc_redist.x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{tmp}\vc_redist.x64.exe"; \
    Parameters: "/install /quiet /norestart"; \
    StatusMsg: "Installing Microsoft Visual C++ Redistributable..."; \
    Check: ShouldInstallVCRedist

Filename: "{tmp}\configure_firewall.bat"; Flags: runhidden waituntilterminated
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "{app}\remove_firewall.bat"; Flags: runhidden waituntilterminated

[UninstallDelete]
Type: filesandordirs; Name: "{sd}\{#MyAppName}_env"

[Code]
function IsVCRedistInstalled(): Boolean;
var
  Installed: Cardinal;
begin
  Result := False;
  if RegQueryDWordValue(HKLM, 'SOFTWARE\Wow6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Installed', Installed) then
  begin
    if Installed = 1 then
      Result := True;
  end;
end;

function ShouldInstallVCRedist(): Boolean;
begin
  if IsVCRedistInstalled() then
  begin
    Log('Visual C++ Redistributable found. Skipping installation.');
    Result := False;
  end
  else
  begin
    Log('Visual C++ Redistributable not found. Proceeding with installation.');
    Result := True;
  end;
end;
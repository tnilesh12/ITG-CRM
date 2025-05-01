[Setup]
AppName=IT-Geeks-CRM
AppVersion=1.0.0
DefaultDirName={localappdata}\Programs\IT-Geeks-CRM
DefaultGroupName=IT-Geeks-CRM
OutputDir=dist
OutputBaseFilename=IT-Geeks-CRM_Installer
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
SetupIconFile=assets/app_logo/app_icon.ico

[Files]
Source: "build/windows/x64/runner/Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs
Source: "webview2_installer.exe"; DestDir: "{tmp}"; Flags: ignoreversion

[Icons]
Name: "{group}\IT-Geeks-CRM"; Filename: "{app}\IT-Geeks-CRM.exe"; WorkingDir: "{app}"; IconFilename: "{app}\assets/app_logo/app_icon.ico"
Name: "{commondesktop}\IT-Geeks-CRM"; Filename: "{app}\IT-Geeks-CRM.exe"; WorkingDir: "{app}"; IconFilename: "{app}\assets/app_logo/app_icon.ico"; Tasks: desktopicon

[Run]
Filename: "{tmp}\webview2_installer.exe"; StatusMsg: "Installing Microsoft WebView2 Runtime..."; Flags: waituntilterminated

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional icons:"

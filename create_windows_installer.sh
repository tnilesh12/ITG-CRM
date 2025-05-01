#!/bin/bash
set -e

APP_NAME="IT-Geeks-CRM"
BUILD_DIR="build/windows/x64/runner/Release"
DIST_DIR="dist"
INNO_SCRIPT="installer_windows.iss"
ICON_PATH="assets/app_logo/app_icon.ico"
WEBVIEW_INSTALLER="webview2_installer.exe"

# 1. Build Flutter Windows app
flutter build windows

# 2. Check if build folder exists
if [ ! -d "$BUILD_DIR" ]; then
  echo "Build folder not found. Run 'flutter build windows' first."
  exit 1
fi

# 3. Create output dir
mkdir -p "$DIST_DIR"

# 4. Copy assets (if any) to build output
cp -R assets "$BUILD_DIR/"

# 5. Write Inno Setup script
cat > "$INNO_SCRIPT" <<EOF
[Setup]
AppName=$APP_NAME
AppVersion=1.0.0
DefaultDirName={localappdata}\\Programs\\$APP_NAME
DefaultGroupName=$APP_NAME
OutputDir=$DIST_DIR
OutputBaseFilename=${APP_NAME}_Installer
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
SetupIconFile=$ICON_PATH

[Files]
Source: "$BUILD_DIR\\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs
Source: "$WEBVIEW_INSTALLER"; DestDir: "{tmp}"; Flags: ignoreversion

[Icons]
Name: "{group}\\$APP_NAME"; Filename: "{app}\\$APP_NAME.exe"; WorkingDir: "{app}"; IconFilename: "{app}\\$ICON_PATH"
Name: "{commondesktop}\\$APP_NAME"; Filename: "{app}\\$APP_NAME.exe"; WorkingDir: "{app}"; IconFilename: "{app}\\$ICON_PATH"; Tasks: desktopicon

[Run]
Filename: "{tmp}\\$WEBVIEW_INSTALLER"; StatusMsg: "Installing Microsoft WebView2 Runtime..."; Flags: waituntilterminated

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional icons:"
EOF

# 6. Compile the installer
iscc "$INNO_SCRIPT"

echo "Installer created: $DIST_DIR/${APP_NAME}_Installer.exe"

#!/usr/bin/env bash
set -ex
SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

apt-get update
apt-get install -y p7zip-full jq unshield coreutils

mkdir -p /opt/ut99
wget https://raw.githubusercontent.com/OldUnreal/FullGameInstallers/master/Linux/install-ut99.sh
chmod +x install-ut99.sh

printf 'Y\n' | ./install-ut99.sh --destination=/opt/ut99/ --ui-mode=none --desktop-shortcut=skip --application-entry=skip

rm install-ut99.sh

# Newer OldUnreal installers put the 64-bit build in System/ instead of System64/
if [ -x /opt/ut99/System64/ut-bin-amd64 ]; then SYSDIR=/opt/ut99/System64; else SYSDIR=/opt/ut99/System; fi
[ -x "$SYSDIR/ut-bin-amd64" ] || { echo "ut-bin-amd64 not found in $SYSDIR" >&2; exit 1; }

cat >/opt/ut99/launch.sh <<EOL
#!/usr/bin/env bash
export LD_LIBRARY_PATH=${SYSDIR}:\$LD_LIBRARY_PATH
if [ -f /opt/VirtualGL/bin/vglrun ] && [ ! -z "\${KASM_EGL_CARD}" ] && [ ! -z "\${KASM_RENDERD}" ] && [ -O "\${KASM_RENDERD}" ] && [ -O "\${KASM_EGL_CARD}" ] ; then
  echo "Starting UT99 with GPU Acceleration on EGL device \${KASM_EGL_CARD}"
  vglrun -d "\${KASM_EGL_CARD}" ${SYSDIR}/ut-bin-amd64 "\$@"
else
    echo "Starting UT99"
    ${SYSDIR}/ut-bin-amd64 "\$@"
fi
EOL

chmod +x /opt/ut99/launch.sh

# Windowed mode + joystick in whichever config files this installer version created
for d in /opt/ut99/System64 /opt/ut99/System; do
  for ini in Default.ini UnrealTournament.ini; do
    [ -f "$d/$ini" ] || continue
    sed -i 's/StartupFullscreen=True/StartupFullscreen=False/' "$d/$ini"
    sed -i 's/UseFullscreen=True/UseFullscreen=False/' "$d/$ini"
    sed -i 's/UseJoystick=False/UseJoystick=True/' "$d/$ini"
  done
  # WASD movement
  for ini in User.ini DefUser.ini; do
    [ -f "$d/$ini" ] || continue
    sed -i 's/^W=.*/W=MoveForward/' "$d/$ini"
    sed -i 's/^A=.*/A=StrafeLeft/' "$d/$ini"
    sed -i 's/^S=.*/S=MoveBackward/' "$d/$ini"
    sed -i 's/^D=.*/D=StrafeRight/' "$d/$ini"
    sed -i 's/^MiddleMouse=MoveForward//' "$d/$ini"
  done
done

chown -R 1000:1000 /opt/ut99

cat >$HOME/Desktop/ut99.desktop <<EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=Unreal Tournament
GenericName=Game
Comment=Unreal Tournament
Exec=/opt/ut99/launch.sh %F
Path=/opt/ut99/
Terminal=false
MimeType=text/plain;
Icon=/opt/ut99/Help/Unreal.ico
Categories=Graphics;Utility;
StartupNotify=true
EOL

chmod +x $HOME/Desktop/ut99.desktop
chown 1000:1000 $HOME/Desktop/ut99.desktop
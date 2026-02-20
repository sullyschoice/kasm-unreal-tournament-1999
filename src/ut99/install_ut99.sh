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

cat >/opt/ut99/launch.sh <<EOL
#!/usr/bin/env bash
export LD_LIBRARY_PATH=/opt/ut99/System64:\$LD_LIBRARY_PATH
if [ -f /opt/VirtualGL/bin/vglrun ] && [ ! -z "\${KASM_EGL_CARD}" ] && [ ! -z "\${KASM_RENDERD}" ] && [ -O "\${KASM_RENDERD}" ] && [ -O "\${KASM_EGL_CARD}" ] ; then
  echo "Starting UT99 with GPU Acceleration on EGL device \${KASM_EGL_CARD}"
  vglrun -d "\${KASM_EGL_CARD}" /opt/ut99/System64/ut-bin-amd64 "\$@"
else
    echo "Starting UT99"
    /opt/ut99/System64/ut-bin-amd64 "\$@"
fi
EOL

chmod +x /opt/ut99/launch.sh

sed -i 's/StartupFullscreen=True/StartupFullscreen=False/' /opt/ut99/System64/Default.ini
sed -i 's/UseFullscreen=True/UseFullscreen=False/' /opt/ut99/System64/Default.ini
sed -i 's/UseJoystick=False/UseJoystick=True/' /opt/ut99/System64/Default.ini

sed -i 's/StartupFullscreen=True/StartupFullscreen=False/' /opt/ut99/System/Default.ini
sed -i 's/UseFullscreen=True/UseFullscreen=False/' /opt/ut99/System/Default.ini
sed -i 's/UseJoystick=False/UseJoystick=True/' /opt/ut99/System/Default.ini

sed -i 's/StartupFullscreen=True/StartupFullscreen=False/' /opt/ut99/System64/UnrealTournament.ini
sed -i 's/UseFullscreen=True/UseFullscreen=False/' /opt/ut99/System64/UnrealTournament.ini
sed -i 's/UseJoystick=False/UseJoystick=True/' /opt/ut99/System64/UnrealTournament.ini

sed -i 's/^W=.*/W=MoveForward/' /opt/ut99/System64/User.ini
sed -i 's/^A=.*/A=StrafeLeft/' /opt/ut99/System64/User.ini
sed -i 's/^S=.*/S=MoveBackward/' /opt/ut99/System64/User.ini
sed -i 's/^D=.*/D=StrafeRight/' /opt/ut99/System64/User.ini
sed -i 's/^MiddleMouse=MoveForward//' /opt/ut99/System64/User.ini

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
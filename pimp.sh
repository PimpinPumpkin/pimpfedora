#!/bin/bash
#First written on May 15th, 2022. Currently using Fedora Workstation 41 on x64 hardware.

#App data must be imported
#Computer name needs to be set
#Power mode needs to be set to performance
#Default applications
#Extensions configuration
#Keyboard shortcuts configuration
#if you're on a laptop, install gesture improvements extension

#Set natural scrolling
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

#Set dark theme
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

#Change clock to AM/PM
gsettings set org.gnome.desktop.interface clock-format '12h'
gsettings set org.gtk.Settings.FileChooser clock-format '12h'
gsettings set org.gtk.gtk4.Settings.FileChooser clock-format '12h'

#Change the locking settings
gsettings set org.gnome.desktop.session idle-delay 900
gsettings set org.gnome.desktop.screensaver idle-activation-enabled 'true'
gsettings set org.gnome.desktop.screensaver lock-enabled 'true'

#Enable more parallel DNF downloads (bad if internet is slow)
echo max_parallel_downloads=10 | sudo tee --append /etc/dnf/dnf.conf

#Add VSCodium repo
sudo tee -a /etc/yum.repos.d/vscodium.repo << 'EOF'
[gitlab.com_paulcarroty_vscodium_repo]
name=gitlab.com_paulcarroty_vscodium_repo
baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
metadata_expire=1h
EOF

#Install Powershell Prerecs
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
VERSION=$(cat /etc/fedora-release | grep -o '[0-9]' | awk '{printf "%s", $0}')
#For some reason only the CentOS 8 package works (as of April 1st 2023 & Feb 13th 2025. Test on Fedora 36, 37, 38, and 41)
#MSPKGRPM=https://packages.microsoft.com/config/fedora/$VERSION/packages-microsoft-prod.rpm
MSPKGRPM=https://packages.microsoft.com/config/centos/8/packages-microsoft-prod.rpm
sudo rpm -Uvh $MSPKGRPM 

#Enable RPM Fusion free and non-free
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

#Install Google GPG key and Google Earth
wget https://dl.google.com/linux/linux_signing_key.pub
sudo rpm --import linux_signing_key.pub
rm linux_signing_key.pub
curl https://dl.google.com/dl/linux/direct/google-earth-pro-stable-current.x86_64.rpm --output google_earth_pro.rpm
sudo dnf localinstall -y google_earth_pro.rpm
sudo rm google_earth_pro.rpm

#Install Librewolf repo
sudo dnf config-manager -y --add-repo https://rpm.librewolf.net/librewolf-repo.repo

#Install known dependencies 
sudo dnf install -y powershell
sudo dnf install -y codium

#Install vscode-powershell
curl -s https://api.github.com/repos/PowerShell/vscode-powershell/releases/latest \
| grep "browser_download_url.*vsix" \
| cut -d : -f 2,3 \
| tr -d \" \
| xargs curl -L -o vscode-powershell.vsix
codium --install-extension vscode-powershell.vsix
rm vscode-powershell.vsix

sudo dnf install -y openssl
sudo dnf install -y gnome-shell-extension-pop-shell xprop
sudo dnf install -y webp-pixbuf-loader #enables webp images in gnome-sushi
sudo dnf install -y libheif #enables HEIF images in gnome-sushi 
sudo dnf install -y alsa-plugins-pulseaudio #fixes Davinci Resolve audio lag
sudo dnf install -y librewolf
sudo dnf install -y firefox
sudo dnf install -y yt-dlp
sudo dnf remove -y gnome-extensions-app
sudo dnf remove -y gnome-tour
sudo dnf remove -y gnome-maps
sudo dnf remove -y gnome-contacts
sudo dnf remove -y gnome-photos
sudo dnf remove -y gnome-weather
sudo dnf remove -y rhythmbox
sudo dnf remove -y totem

#Install adw3-gtk dark theme
flatpak install -y org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
sudo dnf install -y adw-gtk3-theme
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'

#Set pop-shell gaps to zero 
gsettings set org.gnome.shell.extensions.pop-shell gap-inner uint32 0

#Install Flatpaks (Fedora 38 enables Flathub by default)
flatpak install -y flathub com.mattjakeman.ExtensionManager
flatpak install -y flathub com.spotify.Client
flatpak install -y flathub io.github.flattool.Ignition
flatpak install -y flathub com.bitwarden.desktop 
flatpak install -y flathub com.brave.Browser
flatpak install -y flathub org.signal.Signal
flatpak install -y flathub org.standardnotes.standardnotes
flatpak install -y flathub com.github.rafostar.Clapper
flatpak install -y flathub org.gnome.World.PikaBackup
flatpak install -y flathub org.chromium.Chromium
flatpak install -y flathub io.github.seadve.Mousai
flatpak install -y flathub re.sonny.Junction
flatpak install -y flathub org.kde.kwrite
flatpak install -y flathub com.github.IsmaelMartinez.teams_for_linux
flatpak install -y flathub it.mijorus.gearlever #used for generating a .desktop file for appimages

#Configure Signal .desktop file with run in background enabled
# Check if Signal Flatpak is installed
if [ -f '/var/lib/flatpak/exports/share/applications/org.signal.Signal.desktop' ]; then
    # Clean up: remove all instances of --use-tray-icon first
    sudo sed -i 's/ --use-tray-icon//g' '/var/lib/flatpak/exports/share/applications/org.signal.Signal.desktop'
    
    # Add one instance of --use-tray-icon at the correct place
    sudo sed -i 's/%U/%U --use-tray-icon/g' '/var/lib/flatpak/exports/share/applications/org.signal.Signal.desktop'
fi


Anything below this line is outdated/no longer used
##############################

#Make lockscreen 200% scaled (now we have automatically setting fractional scaling which should set GDM as well)
#https://itectec.com/ubuntu/ubuntu-scaling-gnome-login-screen-on-hidpi-display/
#sudo sed -i '/<key name="scaling-factor" type="u">/{n;s/<default>.*<\/default>/<default>2<\/default>/}' '/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml'
#sudo glib-compile-schemas /usr/share/glib-2.0/schemas

#sudo dnf install -y alacarte
#sudo dnf install -y pavucontrol
#sudo dnf install -y glib2-devel #gdm-settings
#sudo dnf install -y java-11-openjdk #JNLP IcedTea
#sudo dnf install -y java-11-openjdk-devel #JNLP IcedTea
#sudo dnf install -y nautilus-image-converter
#sudo dnf install -y alacarte
#sudo dnf install -y pavucontrol

#flatpak install -y io.github.realmazharhussain.GdmSettings #causes issues sometimes

#Install and set fonts (Gnome 48 moves to Adwaita Sans/Inter which looks fine)
#SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#sudo cp -a $SCRIPT_DIR/Google-sans /usr/share/fonts
#sudo cp -a $SCRIPT_DIR/SourceCode-Pro /usr/share/fonts
#gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Google Sans 18pt Bold 11'
#gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro 10'
#gsettings set org.gnome.desktop.interface document-font-name 'Google Sans 18pt Bold 11'
#gsettings set org.gnome.desktop.interface font-name 'Google Sans 18pt Bold 11'

#Install ConnectWise extension for VScode:
#pwsh -c "Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted"
#pwsh -c "Install-Module 'ConnectWiseManageAPI'"
#pwsh -c "Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted"

#Install Iced-Tea for JNLP files/ConnectWise
#curl https://kojipkgs.fedoraproject.org//packages/icedtea-web/2.0.0/pre.0.3.alpha16.patched1.1.fc36.2/x86_64/icedtea-web-2.0.0-pre.0.3.alpha16.patched1.1.fc36.2.x86_64.rpm --output icedtea.rpm
#sudo dnf localinstall -y icedtea.rpm
#sudo rm icedtea.rpm

#Gstreamer stuff from https://gstreamer.freedesktop.org/documentation/installing/on-linux.html?gi-language=c
#sudo dnf install -y gstreamer1-devel
#sudo dnf install -y gstreamer1-plugins-base-tools
#sudo dnf install -y gstreamer1-doc
#sudo dnf install -y gstreamer1-plugins-base-devel
#sudo dnf install -y gstreamer1-plugins-good
#sudo dnf install -y gstreamer1-plugins-good-extras
#sudo dnf install -y gstreamer1-plugins-ugly
#sudo dnf install -y gstreamer1-plugins-bad-free
#sudo dnf install -y gstreamer1-plugins-bad-free-devel
#sudo dnf install -y gstreamer1-plugins-bad-free-extras
###

#As of Feb 13 2025, gnome-sushi is able to play h264 and (but no h265) at least on an intel gpu without any additional packages.
#sudo dnf install -y x264 #enables video in gnome-sushi. Seems there's an issue on install on 39, but things work...
#sudo dnf install -y ffmpeg #maybe unneeded if using va-api patch? Seems there's an issue on install on 39, but things work...
#sudo dnf install -y gstreamer1-libav #maybe unneeded if using va-api patch?
#sudo dnf install -y gstreamer1-plugin-openh264 #ditto, but not sure - needed for h264 in gnome-sushi
###


#As of Feb 13 2025, I am now using Ignition to handle all application startups
#if ! [ -f /home/$USER/.config/autostart/org.signal.Signal.desktop ]; then
#sudo mkdir -p ~/.config/autostart
#sudo echo "[Desktop Entry]
#Name=Start Signal in Tray
#GenericName=signal-start
#Comment=Start Signal in Tray
#Exec=/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=signal-desktop --file-forwarding org.signal.Signal @@u %U @@ --start-in-tray
#Terminal=false
#Type=Application
#X-GNOME-Autostart-enabled=true" | sudo tee --append /home/$USER/.config/autostart/org.signal.Signal.desktop
#fi



#-------------
#Add hardware video acceleration (RPMFusion must be enabled)
#https://github.com/rpmfusion-infra/fedy/issues/110#issuecomment-1311268988

#you could use this if mesa-va and or mesa-vdpau are not already installed:
#sudo dnf install mesa-va-drivers-freeworld 
#sudo dnf install mesa-vdpau-drivers-freeworld

#swap out the old drivers with the HW-accelerated ones
#sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld -y
#commenting out this next line because it wasn't installed by default on my system already:
#sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

#install non-hardware codecs
#sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
#sudo dnf groupupdate -y sound-and-video
#sudo dnf install -y @multimedia @sound-and-video ffmpeg-libs gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav lame\*
#flatpak install -y flathub org.freedesktop.Platform.ffmpeg-full

#------------

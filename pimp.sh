#!/bin/bash
#First written on May 15th, 2022. Currently using Fedora Workstation 38 on x64 hardware.

#App date must be imported
#Computer name needs to be set
#Power mode needs to be set to performance
#Default applications
#Extensions configuration
#Keyboard shortcuts configuration
#if you're on a laptop, install gesture improvements extension

#Make lockscreen 200% scaled
#https://itectec.com/ubuntu/ubuntu-scaling-gnome-login-screen-on-hidpi-display/
sudo sed -i '/<key name="scaling-factor" type="u">/{n;s/<default>.*<\/default>/<default>2<\/default>/}' '/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml'
sudo glib-compile-schemas /usr/share/glib-2.0/schemas

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

#Install and set fonts
sudo cp -a Google-sans /usr/share/fonts
sudo cp -a SourceCode-Pro /usr/share/fonts
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Google Sans 18pt Bold 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro 10'
gsettings set org.gnome.desktop.interface document-font-name 'Google Sans 18pt Bold 11'
gsettings set org.gnome.desktop.interface font-name 'Google Sans 18pt Bold 11'

#Enable more parallel DNF downloads (bad if internet is slow)
echo max_parallel_downloads=10 | sudo tee --append /etc/dnf/dnf.conf

#Enable RPM Fusion free and non-free
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

#Install triple buffering patch from COPR
sudo dnf copr enable -y calcastor/gnome-patched
sudo dnf --refresh upgrade -y

#Install Google GPG key (for when installing Google Earth)
wget https://dl.google.com/linux/linux_signing_key.pub
sudo rpm --import linux_signing_key.pub
rm linux_signing_key.pub

#Install known dependencies 
sudo dnf install -y ninja-build #adw
sudo dnf install -y git
sudo dnf install -y meson #adw3-gtk
sudo dnf install -y sassc #adw3-gtk
sudo dnf install -y x264 #enables video in gnome-sushi
sudo dnf install -y ffmpeg #maybe unneeded if using va-api patch?
sudo dnf install -y gstreamer1-libav #maybe unneeded if using va-api patch?
sudo dnf install -y openssl
sudo dnf install -y gnome-shell-extension-pop-shell xprop
sudo dnf install -y nautilus-image-converter
sudo dnf install -y webp-pixbuf-loader #enables webp images in gnome-sushi
sudo dnf install -y libheif #enables HEIF images in gnome-sushi 
sudo dnf install -y alacarte
sudo dnf install -y pavucontrol
sudo dnf install -y alsa-plugins-pulseaudio #fixes Davinci Resolve audio lag
sudo dnf install -y glib2-devel #gdm-settings
sudo dnf install -y java-11-openjdk #JNLP IcedTea
sudo dnf install -y java-11-openjdk-devel #JNLP IcedTea
sudo dnf install -y firefox
sudo dnf remove -y gnome-extensions-app
sudo dnf remove -y gnome-tour
sudo dnf remove -y gnome-maps
sudo dnf remove -y gnome-contacts
sudo dnf remove -y gnome-photos
sudo dnf remove -y rhythmbox
sudo dnf remove -y totem

#Install adw3-gtk dark theme
flatpak install -y org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
sudo dnf copr enable -y nickavem/adw-gtk3
sudo dnf install -y adw-gtk3
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'

#Set pop-shell gaps to zero 
gsettings set org.gnome.shell.extensions.pop-shell gap-inner uint32 0

#Install Flatpaks (Fedora 38 enables Flathub by default)
flatpak install -y flathub com.mattjakeman.ExtensionManager
flatpak install -y flathub com.spotify.Client
flatpak install -y flathub com.bitwarden.desktop
flatpak install -y flathub com.brave.Browser
flatpak install -y flathub org.signal.Signal
flatpak install -y flathub org.standardnotes.standardnotes
flatpak install -y flathub com.github.neithern.g4music
flatpak install -y flathub com.github.rafostar.Clapper
flatpak install -y flathub org.gnome.World.PikaBackup
flatpak install -y io.github.realmazharhussain.GdmSettings
flatpak install -y flathub io.github.seadve.Mousai
flatpak install -y flathub org.gnome.gitlab.somas.Apostrophe

#Signal auto-start and .desktop config
if ! [ -f /home/$USER/.config/autostart/org.signal.Signal.desktop ]; then
sudo mkdir -p ~/.config/autostart
sudo echo "[Desktop Entry]
Name=Start Signal in Tray
GenericName=signal-start
Comment=Start Signal in Tray
Exec=/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=signal-desktop --file-forwarding org.signal.Signal @@u %U @@ --start-in-tray
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true" | sudo tee --append /home/$USER/.config/autostart/org.signal.Signal.desktop
fi

#Check if Signal Flatpak is installed
if [ -f '/var/lib/flatpak/exports/share/applications/org.signal.Signal.desktop' ]; then
	#If so, make sure we haven't already patched the .desktop file before we attempt to add the --use-tray-icon argument
	if ! [ grep -q "%U @@ --use-tray-icon" '/var/lib/flatpak/exports/share/applications/org.signal.Signal.desktop' ]; then
    		#Configure Signal to use tray icon if manually launched
    		sudo sed -i 's/%U @@/%U @@ --use-tray-icon/g' '/var/lib/flatpak/exports/share/applications/org.signal.Signal.desktop'
	fi
fi

#Install Iced-Tea for JNLP files/ConnectWise
curl https://kojipkgs.fedoraproject.org//packages/icedtea-web/2.0.0/pre.0.3.alpha16.patched1.1.fc36.2/x86_64/icedtea-web-2.0.0-pre.0.3.alpha16.patched1.1.fc36.2.x86_64.rpm --output icedtea.rpm
sudo dnf localinstall -y icedtea.rpm
sudo rm icedtea.rpm

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

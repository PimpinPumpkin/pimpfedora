#!/bin/bash
#First written on May 15th, 2022. Currently using Fedora Workstation 36.

#Computer name needs to be set
#Power mode needs to be set to performance
#Default applications
#extensions


#enable RPM Fusion
echo Enabling RPM Fusion
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
  
sudo dnf install -y \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
 
echo RPM Fusion enabled 
echo Installing dependencies

#Install dependencies for shit I know I need

sudo dnf install -y ninja-build
sudo dnf install -y git
sudo dnf install -y meson
sudo dnf install -y sassc
sudo dnf install -y x264
sudo dnf install -y ffmpeg
sudo dnf install -y gstreamer1-libav
sudo dnf install -y openssl
sudo dnf install -y gnome-shell-extension-pop-shell xprop
sudo dnf install -y nautilus-image-converter
sudo dnf install -y alacarte
#sudo dnf install -y glib2-devel
#sudo dnf install -y dconf
sudo dnf remove -y gnome-extensions-app
sudo dnf remove -y gnome-tour
sudo dnf remove -y gnome-maps
sudo dnf remove -y gnome-contacts
sudo dnf remove -y mediawriter

echo Dependencies installed successfully
echo Installing Legacy GTK4 theme

#install adw3-gtk theme
git clone https://github.com/lassekongo83/adw-gtk3.git
cd adw-gtk3
meson build
sudo ninja -C build install
cd ../
rm -rf $PWD/adw-gtk3

#Make lockscreen 200 percent scaled
#https://itectec.com/ubuntu/ubuntu-scaling-gnome-login-screen-on-hidpi-display/
sudo sed -i '/<key name="scaling-factor" type="u">/{n;s/<default>.*<\/default>/<default>2<\/default>/}' '/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml'

sudo glib-compile-schemas /usr/share/glib-2.0/schemas

#install fonts
git clone https://github.com/PimpinPumpkin/pimpfedora36.git
sudo cp -a Google-sans /usr/share/fonts


#install flatpaks
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub com.mattjakeman.ExtensionManager
flatpak install -y flathub io.freetubeapp.FreeTube
flatpak install -y flathub com.spotify.Client
flatpak install -y flathub com.bitwarden.desktop
flatpak install -y flathub com.brave.Browser
flatpak install -y flathub org.signal.Signal
flatpak install -y flathub org.standardnotes.standardnotes
flatpak install -y flathub io.bassi.Amberol
flatpak install -y flathub com.github.rafostar.Clapper
#flatpak install -y flathub org.gnome.Cheese
flatpak install -y flathub io.lbry.lbry-app
flatpak install -y flathub org.gnome.World.PikaBackup
flatpak install -y flathub io.github.realmazharhussain.GdmSettings


#signal auto-start and config
mkdir ~/.config/autostart

echo "[Desktop Entry]
Name=Start Signal in Tray
GenericName=signal-start
Comment=Start Signal in Tray
Exec=/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=signal-desktop --file-forwarding org.signal.Signal @@u %U @@ --start-in-tray
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true" > ~/.config/autostart/org.signal.Signal.desktop

sudo sed -i 's/%U @@/%U @@ --use-tray-icon/g' '/var/lib/flatpak/exports/share/applications/org.signal.Signal.desktop'


#move window control to the left

gsettings set org.gnome.desktop.wm.preferences button-layout 'close:appmenu'


#if for some reason you want to have maximize and minimize buttons also on the left, it would be:

#gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:appmenu'

#or on the right:

#gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'


#change fonts
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Google Sans 18pt Bold 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'Source Code Pro 10'
gsettings set org.gnome.desktop.interface document-font-name 'Google Sans 18pt Bold 11'
gsettings set org.gnome.desktop.interface font-name 'Google Sans 18pt Bold 11'

#set legacy application theme to adw3
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'

#set pop shell gaps to zero 
gsettings set org.gnome.shell.extensions.pop-shell gap-inner uint32 0

#set natural scrolling
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

#set dark theme
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

#set legacy gtk theme to dark
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'

#change clock to AM/PM

gsettings set org.gnome.desktop.interface clock-format '12h'

gsettings set org.gtk.Settings.FileChooser clock-format '12h'

gsettings set org.gtk.gtk4.Settings.FileChooser clock-format '12h'


#change the locking settings
gsettings set org.gnome.desktop.session idle-delay 900
gsettings set org.gnome.desktop.screensaver idle-activation-enabled 'true'
gsettings set org.gnome.desktop.screensaver lock-enabled 'true'



##NONE OF THIS WORKS


#media key F7 previous
#gsettings set org.gnome.settings-daemon.plugins.media-keys previous ['F7']



#media key F8 play/pause
#gsettings set org.gnome.settings-daemon.plugins.media-keys play ['F8']

#media key F9 next
#gsettings set org.gnome.settings-daemon.plugins.media-keys next ['F9']

#Volume keys to F10, (mute/unmute), F11 (down), F12(up)

#gsettings set org.gnome.settings-daemon.plugins.media-keys volume-mute ['F10']

#gsettings set org.gnome.settings-daemon.plugins.media-keys volume-down ['F11']

#gsettings set org.gnome.settings-daemon.plugins.media-keys volume-up ['F12']

#microphone mute toggle
#gsettings set org.gnome.settings-daemon.plugins.media-keys mic-mute ['Pause']



#switch workspaces left
#gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right ['<Control>Page_Up']

#sudo sed -i '/<key name="switch-to-workspace-left" type="as">/{n;s/<default>.*<\/default>/<default><![CDATA[['\<Super\>Page_Up','\<Super\>\<Alt\>Left','\<Control\>\<Alt\>Left'\]\]\]><\/default>/}' '/usr/share/glib-2.0/schemas/org.gnome.desktop.wm.keybindings.gschema.xml'

#switch workspaces right
#gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right ['<Control>Page_Down']

#sudo sed -i '/<key name="switch-to-workspace-right" type="as">/{n;s/<default>.*<\/default>/<default><![CDATA[['\<Super\>Page_Down','\<Super\>\<Alt\>Right','\<Control\>\<Alt\>Right'\]\]\]><\/default>/}' '/usr/share/glib-2.0/schemas/org.gnome.desktop.wm.keybindings.gschema.xml'

#move current window a workspace to the left
#gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left ['<Shift><Control>Page_Up']

#sudo sed -i '/<key name="switch-to-workspace-left" type="as">/{n;s/<default>.*<\/default>/<default><![CDATA[['\<Super\>\<Shift\>Page_Up','\<Super\>\<Shift\>\<Alt\>Left','\<Control\>\<Shift\>\<Alt\>Left'\]\]\]><\/default>/}' '/usr/share/glib-2.0/schemas/org.gnome.desktop.wm.keybindings.gschema.xml'

#move current window a workspace to the right
#gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right ['<Shift><Control>Page_Down']

#sudo sed -i '/<key name="switch-to-workspace-right" type="as">/{n;s/<default>.*<\/default>/<default><![CDATA[['\<Super\>\<Shift\>Page_Down','\<Super\>\<Shift\>\<Alt\>Right','\<Control\>\<Shift\>\<Alt\>Right'\]\]\]><\/default>/}' '/usr/share/glib-2.0/schemas/org.gnome.desktop.wm.keybindings.gschema.xml'


#control q to quit
#gsettings set org.gnome.Terminal.Legacy.Keybindings close-window '<Control><Shift>q'

#open terminal with ctrl alt t
#gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Primary><Alt>t']"

#compile all these settings and update
#sudo glib-compile-schemas /usr/share/glib-2.0/schemas



#launch gnome settings

#gnome-control-center < /dev/null &


#Installing GDM-tools is not really neccesary because we have the gui application which does more
#Install gdm-tools
#git clone --depth=1 --single-branch https://github.com/realmazharhussain/gdm-tools.git
#./gdm-tools/install.sh

#rm -rf $PWD/gdm-tools

#set-gdm-theme set default /usr/share/backgrounds/gnome/blobs-d.svg

#gnomeconf2gdm

#sudo rm /etc/dconf/db/gdm.d/99-gnomeconf2gdm


#!/bin/bash

#Fedora Packet Tracer 7.3.0 (.deb) install yr.2020 (could work for openSUSE, but havent tested it)

## configuring OS veribles
. /etc/os-release
if [[ $NAME = Fedora* ]]
then ins="dnf" && os="$NAME"_"$VERSION_ID"
elif [[ ! -z "$OSTREE_VERSION" ]] #For Silverteam
then ins='rpm-ostree' && os="$NAME"_"$VERSION_ID"
elif  [[ $NAME = "openSUSE Leap" ]]
then ins="zypper" && os="$NAME"_"$VERSION_ID"
elif  [[ $NAME = "openSUSE Tumbleweed" ]]
then ins="zypper" && os=$NAME
else echo "can't find distro name, assuming openSUSE" && upd="sudo zypper dup -y" && os=$NAME
fi

# Cisco Packet Tracer version (7.3.0 = 730)
version=730

# Download required rpm's
sudo $ins install qt5-qtwebkit qt5-qtsvg qt5-qtscript libpng12 git qt5-qtwayland-devel	double-conversion

#get file from www.netacad.com
wget {incert .deb here}
https://www.netacad.com/portal/resources/file/aa38a51f-45bb-4eb1-89a0-01d961ae1432

#Folling code (to line 47) from [von Andreas Grupp](https://grupp-web.de/cms/2020/01/03/installation-of-packet-tracer-7-3-on-rpm-linux-systems-without-alien/)
mkdir /tmp/PacketTracerInst
cp "PacketTracer_"$version"_amd64.deb /tmp/PacketTracerInst"
#rm "PacketTracer_"$version"_amd64.deb"
cd /tmp/PacketTracerInst
ar -xv "PacketTracer_"$version"_amd64.deb"
mkdir control
tar -C control -Jxf control.tar.xz
mkdir data
tar -C data -Jxf data.tar.xz
cd data

# remove old versions
rm -rf /opt/pt
rm -rf /usr/share/applications/cisco-pt7.desktop
rm -rf /usr/share/applications/cisco-ptsa7.desktop
rm -rf /usr/share/icons/hicolor/48x48/apps/pt7.png

cp -r usr /
cp -r opt /

ln -s /usr/lib64/libdouble-conversion.so.3.1.5 /usr/lib64/libdouble-conversion.so.1

# 'update icon and file assocation'
sudo xdg-desktop-menu install /usr/share/applications/cisco-pt7.desktop
sudo xdg-desktop-menu install /usr/share/applications/cisco-ptsa7.desktop
sudo update-mime-database /usr/share/mime
sudo gtk-update-icon-cache --force --ignore-theme-index /usr/share/icons/gnome
sudo xdg-mime default cisco-ptsa7.desktop x-scheme-handler/pttp

sudo ln -sf /opt/pt/packettracer /usr/local/bin/packettracer
#create gnome .desktop file
sudo cp /opt/pt/bin/Cisco-PacketTracer.desktop /usr/share/applications/

# Add enviroment settings
sudo bash -c 'cat >> /etc/profile <<EOL
PT7HOME=/opt/pt
export PT7HOME
QT_DEVICE_PIXEL_RATIO=auto
export QT_DEVICE_PIXEL_RATIO
EOL'


# install libcrypto.so.1.0.0 (source from sincorchetes on github)
git clone https://github.com/sincorchetes/packettracer
cd packettracer
cp libcrypto.so.1.0.0 /opt/pt/bin/
cd ..
sudo rm -r packettracer

# install libjpeg.so.8 (from my repo on 'openSUSE Build' made by the Graphics Project (openSUSE Factory Team))
sudo $ins config-manager --add-repo "https://download.opensuse.org/repositories/home:GeoDerp:branches:graphics/"$os"/home:GeoDerp:branches:graphics.repo"
##dnf remove libjpeg-turbo --noautoremove -y ## add if having issues with previous packadges
##dnf remove libjpeg62-turbo --noautoremove -y ## add if having issues with previous packadges
sudo $ins install --enablerepo=home_GeoDerp_branches_graphics libjpeg-turbo libjpeg62-turbo -y #note if qt5(PacketTracer) dosnt find it, you can find libjpeg.so.8 manually and cp it over (EX. sudo cp /usr/lib/libjpeg.so.8 /opt/pt/bin/)

#### add text in packettracerrun file
sed '/3/ a export QT_QPA_PLATFORM=\"wayland;xcb\"' /opt/pt/packettracer > /tmp/packettracer
sudo cp /tmp/packettracer /opt/pt/packettracer && sudo rm /tmp/packettracer

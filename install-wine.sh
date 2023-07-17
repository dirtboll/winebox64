#!/bin/bash
set -euxo pipefail
# NOTE: Can only run on aarch64 (since box64 can only run on aarch64)
# box64 runs wine-amd64, box86 runs wine-i386.

### User-defined Wine version variables ################
# - Replace the variables below with your system's info.
# - Note that we need the amd64 version for Box64 even though we're installing it on our ARM processor.
# - Note that we need the i386 version for Box86 even though we're installing it on our ARM processor.
# - Wine download links from WineHQ: https://dl.winehq.org/wine-builds/

branch="stable" #example: devel, staging, or stable (wine-staging 4.5+ requires libfaudio0:i386)
version="7.0.2" #example: "7.1"
id="debian" #example: debian, ubuntu
dist="bookworm" #example (for debian): bullseye, buster, jessie, wheezy, ${VERSION_CODENAME}, etc 
tag="-1" #example: -1 (some wine .deb files have -1 tag on the end and some don't)

########################################################

# Wine download links from WineHQ: https://dl.winehq.org/wine-builds/
LNKA="https://dl.winehq.org/wine-builds/${id}/dists/${dist}/main/binary-amd64/" #amd64-wine links
DEB_A1="wine-${branch}-amd64_${version}~${dist}${tag}_amd64.deb" #wine64 main bin
DEB_A2="wine-${branch}_${version}~${dist}${tag}_amd64.deb" #wine64 support files (required for wine64 / can work alongside wine_i386 main bin)
DEB_A3="winehq-${branch}_${version}~${dist}${tag}_amd64.deb" #shortcuts & docs
LNKB="https://dl.winehq.org/wine-builds/${id}/dists/${dist}/main/binary-i386/" #i386-wine links
DEB_B1="wine-${branch}-i386_${version}~${dist}${tag}_i386.deb" #wine_i386 main bin
DEB_B2="wine-${branch}_${version}~${dist}${tag}_i386.deb" #wine_i386 support files (required for wine_i386 if no wine64 / CONFLICTS WITH wine64 support files)
DEB_B3="winehq-${branch}_${version}~${dist}${tag}_i386.deb" #shortcuts & docs

# Install amd64-wine (64-bit) alongside i386-wine (32-bit)
echo -e "Downloading wine . . ."
wget -q ${LNKA}${DEB_A1} 
wget -q ${LNKA}${DEB_A2} 
wget -q ${LNKB}${DEB_B1} 

echo -e "Extracting wine . . ."
dpkg-deb -x ${DEB_A1} wine-installer
dpkg-deb -x ${DEB_A2} wine-installer
dpkg-deb -x ${DEB_B1} wine-installer
echo -e "Installing wine . . ."
mv wine-installer/opt/wine* ~/wine

# Clean up
rm -rf ${DEB_A1} ${DEB_A2} ${DEB_B1}

# Download wine dependencies
# - these packages are needed for running box86/wine-i386 on a 64-bit RPiOS via multiarch
dpkg --add-architecture armhf && apt-get update # enable multi-arch
apt-get install -y libasound2-plugins:armhf libasound2:armhf libc6:armhf libcapi20-3:armhf libcups2:armhf libdbus-1-3:armhf libfontconfig1:armhf libfreetype6:armhf libglib2.0-0:armhf libglu1-mesa:armhf libgnutls30:armhf libgphoto2-6:armhf libgphoto2-port12:armhf libgsm1:armhf libgssapi-krb5-2:armhf libgstreamer-plugins-base1.0-0:armhf libgstreamer1.0-0:armhf libjpeg62-turbo:armhf libkrb5-3:armhf libncurses6:armhf libodbc1:armhf libosmesa6:armhf libpcap0.8:armhf libpng16-16:armhf libpulse0:armhf libsane1:armhf libsdl2-2.0-0:armhf libtiff6:armhf libudev1:armhf libunwind8:armhf libusb-1.0-0:armhf libv4l-0:armhf libx11-6:armhf libxcomposite1:armhf libxcursor1:armhf libxext6:armhf libxfixes3:armhf libxi6:armhf libxinerama1:armhf libxrandr2:armhf libxrender1:armhf libxslt1.1:armhf libxxf86vm1:armhf ocl-icd-libopencl1:armhf # to run wine-i386 through box86:armhf on aarch64
    # This list found by downloading...
    #	wget https://dl.winehq.org/wine-builds/debian/dists/bookworm/main/binary-i386/wine-staging-i386_8.11~bookworm-1_i386.deb
    #	wget https://dl.winehq.org/wine-builds/debian/dists/bookworm/main/binary-i386/wine-staging_8.11~bookworm-1_i386.deb
    #	wget https://dl.winehq.org/wine-builds/debian/dists/bookworm/main/binary-i386/winehq-staging_8.11~bookworm-1_i386.deb
    # then `dpkg-deb -I package.deb`. Read output, add `:armhf` to packages in dep list, then try installing them on Pi aarch64.
    
# - these packages are needed for running box64/wine-amd64 on RPiOS (box64 only runs on 64-bit OS's)
apt-get install -y libasound2-plugins:arm64 libasound2:arm64 libc6:arm64 libcapi20-3:arm64 libcups2:arm64 libdbus-1-3:arm64 libfontconfig1:arm64 libfreetype6:arm64 libglib2.0-0:arm64 libglu1-mesa:arm64 libgnutls30:arm64 libgphoto2-6:arm64 libgphoto2-port12:arm64 libgsm1:arm64 libgssapi-krb5-2:arm64 libgstreamer-plugins-base1.0-0:arm64 libgstreamer1.0-0:arm64 libjpeg62-turbo:arm64 libkrb5-3:arm64 libncurses6:arm64 libodbc1:arm64 libosmesa6:arm64 libpcap0.8:arm64 libpng16-16:arm64 libpulse0:arm64 libsane1:arm64 libsdl2-2.0-0:arm64 libtiff6:arm64 libudev1:arm64 libusb-1.0-0:arm64 libv4l-0:arm64 libx11-6:arm64 libxcomposite1:arm64 libxcursor1:arm64 libxext6:arm64 libxfixes3:arm64 libxi6:arm64 libxinerama1:arm64 libxrandr2:arm64 libxrender1:arm64 libxslt1.1:arm64 libxxf86vm1:arm64 ocl-icd-libopencl1:arm64 
    # This list found by downloading...
    #	wget https://dl.winehq.org/wine-builds/debian/dists/bookworm/main/binary-amd64/wine-staging-amd64_8.11~bookworm-1_amd64.deb
    #	wget https://dl.winehq.org/wine-builds/debian/dists/bookworm/main/binary-amd64/wine-staging_8.11~bookworm-1_amd64.deb
    #   wget https://dl.winehq.org/wine-builds/debian/dists/bookworm/main/binary-amd64/winehq-staging_8.11~bookworm-1_amd64.deb
    # then `dpkg-deb -I package.deb`. Read output, add `:arm64` to packages in dep list, then try installing them on Pi aarch64.	

# These packages are needed for running wine-staging on RPiOS (Credits: chills340)
apt install libstb0 -y
cd ~
wget -r -l1 -np -nd -A "libfaudio0_*~bpo10+1_i386.deb" http://ftp.us.debian.org/debian/pool/main/f/faudio/ # Download libfaudio i386 no matter its version number
dpkg-deb -xv libfaudio0_*~bpo10+1_i386.deb libfaudio
cp -TRv libfaudio/usr/ /usr/

# Install winetricks
wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks
mv winetricks /usr/local/bin/

# Clean up
rm libfaudio0_*~bpo10+1_i386.deb 
rm -rf libfaudio 
apt-get -y autoremove 
apt-get clean autoclean 
rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists

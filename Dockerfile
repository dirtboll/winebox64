FROM ubuntu:21.10

USER root

ENV DEBIAN_FRONTEND="noninteractive"
RUN dpkg --add-architecture armhf \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests git cmake cabextract gcc-arm-linux-gnueabihf libc6-dev-armhf-cross libc6:armhf systemctl binfmt-support wget

WORKDIR /usr
RUN git clone https://github.com/eckucukoglu/arm-linux-gnueabihf

WORKDIR /root
RUN git clone https://github.com/ptitSeb/box86 \
    && cd box86 \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc -DCMAKE_C_COMPILER_TARGET=arm-linux-gnueabihf -DARM_DYNAREC=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    && make -j3 \
    && make install 
RUN git clone https://github.com/ptitSeb/box64 \
    && cd box64 \
    && mkdir build \
    && cd build \
    && cmake .. -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    && make -j3 \
    && make install 

WORKDIR /root/Downloads
RUN wget https://dl.winehq.org/wine-builds/debian/dists/buster/main/binary-i386/wine-stable-i386_6.0.2~buster-1_i386.deb \
    && wget https://dl.winehq.org/wine-builds/debian/dists/buster/main/binary-i386/wine-stable_6.0.2~buster-1_i386.deb \
    && wget https://dl.winehq.org/wine-builds/debian/dists/buster/main/binary-amd64/wine-stable-amd64_6.0.2~buster-1_amd64.deb \
    && wget https://dl.winehq.org/wine-builds/debian/dists/buster/main/binary-amd64/wine-stable_6.0.2~buster-1_amd64.deb \
    && dpkg-deb -xv wine-stable-i386_6.0.2~buster-1_i386.deb wine-installer \
    && dpkg-deb -xv wine-stable_6.0.2~buster-1_i386.deb wine-installer \
    && dpkg-deb -xv wine-stable-amd64_6.0.2~buster-1_amd64.deb wine-installer \
    && dpkg-deb -xv wine-stable_6.0.2~buster-1_amd64.deb wine-installer \
    && mv ~/Downloads/wine-installer/opt/wine* ~/wine \
    && rm -rf wine-installer

RUN ln -s ~/wine/bin/wine /usr/local/bin/wine \
    && ln -s ~/wine/bin/wineboot /usr/local/bin/wineboot \
    && ln -s ~/wine/bin/winecfg /usr/local/bin/winecfg \
    && ln -s ~/wine/bin/wineserver /usr/local/bin/wineserver \
    && chmod +x /usr/local/bin/wine /usr/local/bin/wineboot /usr/local/bin/winecfg /usr/local/bin/wineserver

RUN echo 'alias wine64="WINEPREFIX=~/.wine64 wine"' >> /root/.bashrc

WORKDIR /root
CMD ["bash"]
ENTRYPOINT ["sh", "-c", "update-binfmts", "--enable", "&&", "bash", "-c"]

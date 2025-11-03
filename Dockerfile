FROM debian:bookworm-slim
LABEL maintainer="Adam Duskett <aduskett@gmail.com>" \
description="Everything needed to run MCUExpresso in a docker container with X11 forwarding."

ARG IDE_VERSION
ARG LINK_SERVER_VERSION
ARG USERNAME
ARG UID
ARG GID

COPY ./mcuxpressoide-${IDE_VERSION}.x86_64.deb.bin /tmp

RUN set -e; \
    apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        dpkg \
        git \
        openjdk-17-jdk \
        libcanberra-gtk3-module \
        libusb-1.0-0-dev \
        libncurses5 \
        packagekit-gtk3-module \
        libwebkit2gtk-4.0-37 \
        dbus-x11 \
        udev \
        libxcb-render-util0 \
        libxcb-shape0 \
        libxcb-icccm4 \
        libxcb-keysyms1 \
        libxcb-image0 \
        libsm6 \
        libice6 \
        && rm -rf /var/lib/apt/lists/*

# Install dfu-util from Debian repositories (newer version available)
RUN apt-get update && apt-get install -y --no-install-recommends dfu-util && rm -rf /var/lib/apt/lists/*

RUN set -e; \
    groupadd -g ${GID} -o ${USERNAME}; \
    useradd -ms /bin/bash -u ${UID} -g ${GID} ${USERNAME}; \
    usermod -aG dialout ${USERNAME}; \
    mkdir -p /home/${USERNAME} ; \
    echo "alias ls='ls --color=auto'" >> /home/${USERNAME}/.bashrc; \
    echo "PS1='\u@\H [\w]$ '" >> /home/${USERNAME}/.bashrc; \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME};

RUN set -e; \
    cd /tmp/; \
    mkdir -p /tmp/mcu/; \
    chmod a+x ./mcuxpressoide-${IDE_VERSION}.x86_64.deb.bin; \
    ./mcuxpressoide-${IDE_VERSION}.x86_64.deb.bin --noexec --target /tmp/mcu; \
    cd /tmp/mcu; \
    dpkg --unpack ./JLink_Linux_x86_64.deb || true; \
    rm -f /var/lib/dpkg/info/jlink.postinst; \
    dpkg --configure -a; \
    dpkg --unpack mcuxpressoide-${IDE_VERSION}.x86_64.deb; \
    rm -f /var/lib/dpkg/info/mcuxpressoide.postinst; \
    dpkg --configure -a; \
    mkdir -p /usr/share/NXPLPCXpresso; \
    chmod a+w /usr/share/NXPLPCXpresso; \
    ln -s /usr/local/mcuxpressoide-${IDE_VERSION} /usr/local/mcuxpressoide; \
    ln -sf /usr/local/mcuxpressoide-${IDE_VERSION}/ide/mcuxpressoide /usr/bin/mcuxpressoide; \
    rm -rf /tmp/mcuxpressoide-${IDE_VERSION}.x86_64.deb.bin /tmp/mcu

RUN set -e; \
    apt-get install -y --no-install-recommends dbus-x11

## Installation of Link Server
COPY ./LinkServer_${LINK_SERVER_VERSION}.x86_64.deb.bin /tmp

RUN set -e; \
    cd /tmp/; \
    mkdir -p /tmp/linkserver/; \
    chmod a+x ./LinkServer_${LINK_SERVER_VERSION}.x86_64.deb.bin; \
    ./LinkServer_${LINK_SERVER_VERSION}.x86_64.deb.bin --noexec --target /tmp/linkserver; \
    cd /tmp/linkserver; \
    dpkg --unpack ./LinkServer_25.7.33.x86_64.deb || true; \
    rm -f /var/lib/dpkg/info/linkserver_25.7.33.postinst; \
    dpkg --configure -a; \
    dpkg --unpack ./MCU-Link.deb || true; \
    rm -f /var/lib/dpkg/info/mcu-link_installer_3.160.postinst; \
    dpkg --configure -a

# Clean up apt cache to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER ${USERNAME}
WORKDIR /home/${USERNAME}
CMD ["/usr/bin/mcuxpressoide"]

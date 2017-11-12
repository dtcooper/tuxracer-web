FROM ubuntu:16.04

# Use serviceable environment variables
ENV RESOLUTION=800x600
ENV PASSWORD=
ENV VERBOSE=

EXPOSE 6080

# Installs:
#   * extreme tux racer :)
#   * xvfb - Virtual frame buffer for X
#   * pulse - We'll a pulse server + dummy audio sink or tuxracer crashes
#   * x11vnc - VNC server
#   * supervisor - Runs daemons
#   - Dependencies for installing noVNC (net-tools, python-numpy, wget+certificates)
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y dist-upgrade \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        extremetuxracer \
        net-tools \
        pulseaudio \
        python-numpy \
        supervisor \
        wget \
        x11vnc \
        xvfb \
    && apt-get -y --purge autoremove \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC
RUN mkdir -p /opt/noVNC/utils/websockify \
    && wget -qO - https://github.com/novnc/noVNC/archive/v0.6.2.tar.gz \
        | tar xz --strip-components=1 -C /opt/noVNC \
    && wget -qO - https://github.com/novnc/websockify/archive/master.tar.gz \
        | tar xz --strip-components=1 -C /opt/noVNC/utils/websockify \
    && cp /opt/noVNC/vnc_auto.html /opt/noVNC/index.html

# Better init (CTRL+C works)
RUN wget -qO /bin/tini https://github.com/krallin/tini/releases/download/v0.16.1/tini \
    && chmod +x /bin/tini

ADD entrypoint.sh /opt/entrypoint.sh

WORKDIR /root
ENTRYPOINT ["/bin/tini", "--", "/opt/entrypoint.sh"]

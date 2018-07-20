FROM ubuntu:18.04
LABEL maintainer "David Cooper <david@dtcooper.com>"

# Use serviceable environment variables
ENV RESOLUTION=800x600
ENV PASSWORD=
ENV VERBOSE=
ENV ICECAST=

EXPOSE 80

# Installs:
#   * extreme tux racer :)
#   * xvfb - Virtual frame buffer for X
#   * pulse - We'll a pulse server + dummy audio sink or tuxracer crashes
#   * x11vnc - VNC server
#   * supervisor - Runs daemons
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y dist-upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        extremetuxracer \
        icecast2 \
        ices2 \
        nginx \
        pulseaudio \
        supervisor \
        wget \
        x11vnc \
        xvfb \
    && apt-get -y --purge autoremove \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC
RUN wget -qO - https://github.com/noVNC/noVNC/archive/master.tar.gz \
        | tar xz --strip-components=1 -C /var/www/html \
    && ln -s /var/www/html/vnc_lite.html /var/www/html/index.html

# Better init (CTRL+C works)
RUN wget -qO /sbin/tini https://github.com/krallin/tini/releases/download/v0.18.0/tini \
    && chmod +x /sbin/tini

ADD image /

WORKDIR /root
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

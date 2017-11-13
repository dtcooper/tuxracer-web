FROM ubuntu:16.04
LABEL maintainer "David Cooper <david@dtcooper.com>"

# Use serviceable environment variables
ENV RESOLUTION=800x600
ENV PASSWORD=
ENV VERBOSE=

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
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        extremetuxracer \
        nginx \
        pulseaudio \
        supervisor \
        wget \
        x11vnc \
        xvfb \
    && apt-get -y --purge autoremove \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC
RUN mkdir /tmp/noVNC \
    && wget -qO - https://github.com/dtcooper/noVNC/archive/master.tar.gz \
        | tar xz --strip-components=1 -C /var/www/html \
    && cp /var/www/html/vnc_lite.html /var/www/html/index.html

# Better init (CTRL+C works)
RUN wget -qO /bin/tini https://github.com/krallin/tini/releases/download/v0.16.1/tini \
    && chmod +x /bin/tini

ADD image /

WORKDIR /root
ENTRYPOINT ["/bin/tini", "--", "/entrypoint.sh"]

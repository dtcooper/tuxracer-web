#!/bin/bash

# Squelch "Failed to open joystick /dev/input/js0" style errors
mkdir -p /dev/input
ln -s /dev/null /dev/input/js0
ln -s /dev/null /dev/input/js1

START_ICECAST=

# We're on linux and have a sound file or get an external pulse server
if [ ! -e /dev/snd -a -z "$PULSE_SERVER" ]; then
    if [ -d /root/.config/pulse ]; then
        MAC_IP="$(getent hosts docker.for.mac.localhost)"
        if [ "$MAC_IP" ]; then
            # I see PulseAudio config! Let's set the right environment variable,
            export PULSE_SERVER='docker.for.mac.localhost'
        else
            echo
            echo "Your version of Docker doesn't support hostname 'docker.for.mac.localhost'."
            echo "You can still use audio, but you'll have to set the PULSE_SERVER environment"
            echo "variable to the host machine's public IP address. Try adding the following to"
            echo "your 'docker run' command"
            echo
            echo "    \$ docker run -e PULSE_SERVER=1.2.3.4 <args>"
            echo
            exit 0
        fi
    else
        # Start dummy pulseaudio server to avoid error messages
        pulseaudio -n -v \
            --load=module-native-protocol-unix \
            --load=module-always-sink \
            --log-target=file:/var/log/pulseaudio.log \
            --start

        if [ "$ICECAST" ]; then
            START_ICECAST=1

            # Include autoplay.js in noVNC
            sed -i 's/<\/body>/<\/body>\n<script src="autoplay.js"><\/script>\n/' \
                /var/www/html/vnc.html /var/www/html/vnc_lite.html

            if [ "$PASSWORD" ]; then
                export ICECAST_PASSWORD="$PASSWORD"
            else
                # Set a random icecast password
                export ICECAST_PASSWORD="$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 32)"
            fi
            sed -i "s/hackme/$ICECAST_PASSWORD/" /etc/icecast2/icecast.xml /etc/ices2.xml
        fi
    fi
fi

# Prep supervisord config file
URL='http://localhost/'
if [ "$PASSWORD" ]; then
    sed -i "s/^\(command.*x11vnc.*\)$/\1 -passwd '$PASSWORD'/" /etc/supervisor/conf.d/etr.conf
    URL="$URL?password=$PASSWORD"
fi

supervisord -c /etc/supervisor/supervisord.conf

# Start Icecast services
if [ "$START_ICECAST" ]; then
    supervisorctl start icecast 2>&1 >/dev/null
    supervisorctl start ices2 2>&1 >/dev/null
fi

echo
echo 'Web server running on port 80:'
echo "    - $URL"
echo

if [ "$#" -gt 0 ]; then
    exec $@
else
    if [ -z "$VERBOSE" ]; then
        exec sleep infinity
    else
        exec tail -F \
            /var/log/xvfb-etr.log \
            /var/log/xvfb-etr.err \
            /var/log/x11vnc.log \
            /var/log/x11vnc.err \
            /var/log/ices2.log \
            /var/log/ices2.err \
            /var/log/icecast2/access.log \
            /var/log/icecast2/error.log \
            /var/log/nginx/access.log \
            /var/log/nginx/error.log \
            /var/log/pulseaudio.log \
            /var/log/supervisor/supervisord.log 2>/dev/null
    fi
fi

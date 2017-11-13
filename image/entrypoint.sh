#!/bin/bash

# Squelch "Failed to open joystick /dev/input/js0" style errors
mkdir -p /dev/input
ln -s /dev/null /dev/input/js0
ln -s /dev/null /dev/input/js1

# We're on linux and have a sound file
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
        pulseaudio --start 2> /dev/null
    fi

fi

# Prep supervisord config file
URL='http://localhost/'
if [ "$PASSWORD" ]; then
    export EXTRA_VNC_ARGS=" -passwd '$PASSWORD'"
    URL="$URL?password=$PASSWORD"
else
    export EXTRA_VNC_ARGS=
fi

echo $$ > /var/run/entrypoint.pid
supervisord -c /etc/supervisor/supervisord.conf

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
            /var/log/nginx/access.log \
            /var/log/nginx/error.log \
            /var/log/supervisor/supervisord.log 2>/dev/null
    fi
fi

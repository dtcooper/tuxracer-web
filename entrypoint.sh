#!/bin/bash

supervisord -c /etc/supervisor/supervisord.conf

echo
echo "Web server running on port 6080:"
if [ -z "$PASSWORD" ]; then
    echo "     - http://localhost:6080/"
else
    echo "     - http://localhost:6080/?password=$PASSWORD"
fi
echo

if [ -z "$@" ]; then
    if [ -z "$VERBOSE" ]; then
        exec sleep infinity
    else
        exec tail -F \
            /var/log/xvfb-etr.log \
            /var/log/xvfb-etr.err \
            /var/log/x11vnc.log \
            /var/log/x11vnc.err \
            /var/log/novnc.log \
            /var/log/novnc.err \
            /var/log/supervisor/supervisord.log 2>/dev/null
    fi
else
    exec "$@"
fi

#!/bin/bash
# Start VNC server on display :1 with the specified geometry and color depth
vncserver :1 -geometry 1920x1080 -depth 24

# Start websockify to bridge the VNC server port to a WebSocket port
# --web /usr/share/novnc/ tells websockify to serve the noVNC client files
/usr/bin/websockify --web /usr/share/novnc/ 6901 localhost:5901

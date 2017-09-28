#!/bin/bash

# Configuration
PI_IP=10.42.0.99
PI_USER=pi
VNC_PORT=5900
DEVICE="VIRTUAL1"
LOCATION="--right-of eDP1"

WIDTH=1680
HEIGHT=1050
FREQ=60

# Result variables
REMOTE=${PI_USER}@${PI_IP}

# Setup Virtual device mode
MODELINE=$(gtf ${WIDTH} ${HEIGHT} ${FREQ} | sed -n 's/.*Modeline "\([^" ]\+\)" \(.*\)/\1 \2/p')
NAME=$(echo "${MODELINE}" | grep -Po '^.*? ' | sed 's/ $//g')

xrandr --delmode "$DEVICE" "${NAME}"
xrandr --rmmode "${NAME}"
xrandr --newmode ${MODELINE}
xrandr --addmode "$DEVICE" "${NAME}"
xrandr --output $DEVICE --mode $NAME ${LOCATION}

# Create a temporary directory for PIDs and logs
TMPD=/tmp/extra_screen
if ! [[ -d $TMPD ]]; then
    mkdir -p $TMPD
fi

# Generate a unique password
PASSWORD=$(openssl rand -hex 50 | vncpasswd -f | tee ${TMPD}/vncpw)
scp ${TMPD}/vncpw ${REMOTE}:~/.ava_vncpw

# Open an ssh tunnel
nohup ssh -2tnNv -R ${VNC_PORT}:localhost:${VNC_PORT} ${REMOTE} > ${TMPD}/tunnel_log 2>&1 &
SSH_PID=$!
echo -n ${SSH_PID} > ${TMPD}/tunnel_pid

# Start the VNC server
CLIP=$(xrandr | grep "^${DEVICE}.*$" | grep -o '[0-9]*x[0-9]*+[0-9]*+[0-9]*')
nohup x11vnc -clip ${CLIP} -noxinerama -noxrandr \
      -repeat -localhost -nevershared -forever \
      -rfbauth ${TMPD}/vncpw \
      -nowf -noncache -wait 1 -defer 1 > ${TMPD}/x11vnc_log.log 2>&1 &
VNC_PID=$!
echo -n ${VNC_PID} > ${TMPD}/x11vnc_pid

# Add kill script
KILL=$TMPD/kill.sh
echo "#!/bin/sh" > $KILL
echo -n "kill $(cat $TMPD/tunnel_pid) && " >> $KILL
echo -n "kill $(cat $TMPD/x11vnc_pid) && " >> $KILL
echo "echo \"Killed x11vnc and SSH.\"" >> $KILL
chmod +x $KILL

# Launch the VNCViewer
ssh $REMOTE 'DISPLAY=:0 vncviewer localhost:0 -passwd ~/.ava_vncpw \
             -viewonly -fullscreen -encodings "copyrect tight"'

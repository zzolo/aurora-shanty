#!/bin/bash
# Start Aurora sketch
# vncserver -kill :1


export USER=pi
export HOME=/home/pi

if [ -e "$HOME/.bashrc" ]
then
  source $HOME/.bashrc
fi

#export DISPLAY=:1
PROCESSING_CMD=/usr/local/bin/processing-java

# Start VNC.  We want to make sure this happens
# /home/pi/aurora-shanty/deploy/tightvnc.sh > /home/pi/aurora.log 2>&1;

# Start X11VNC
x11vnc > /home/pi/x11vnc.log 2>&1;


# Start sketch
$PROCESSING_CMD --sketch=/home/pi/aurora-shanty/aurora_sketch --output=/home/pi/aurora-shanty/aurora_output --force --run

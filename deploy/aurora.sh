#!/bin/bash
# Start Aurora sketch
# vncserver -kill :1


export USER=pi
export HOME=/home/pi
export DISPLAY=:1

if [ -e "$HOME/.bashrc" ]
then
  source $HOME/.bashrc
fi

# Start VNC.  We want to make sure this happens
/home/pi/aurora-shanty/deploy/tightvnc.sh > /home/pi/aurora.log 2>&1;

# Start sketch
processing-java --sketch=/home/pi/aurora-shanty/aurora_sketch --output=/home/pi/aurora-shanty/aurora_output --force --run

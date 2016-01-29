#!/bin/bash
# Start VNC
# vncserver -kill :1


export USER=pi
export HOME=/home/pi

if [ -e "$HOME/.bashrc" ]
then
  source $HOME/.bashrc
fi

vncserver :1

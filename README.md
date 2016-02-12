# Aurora Shanty

Code and documentation for the [Aurora Shanty](http://aurora-shanty.tumblr.com/).

## Raspberry Pi deploy

* Get [Raspbian](https://www.raspberrypi.org/downloads/raspbian/)
* System settings
    * Expand filesystem
    * Boot to CLI
    * Enable I2C
* (optional) [WiFi setup](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md)
* (optional) [Mausberry power switch](http://mausberry-circuits.myshopify.com/pages/setup)
* `sudo apt-get update && sudo apt-get upgrade` (can take a while)

sudo apt-get install libgl1-mesa-dri


/home/pi/.xsessionrc
# Start X11VNC
x11vnc -bg -nevershared -forever -tightfilexfer -nopw -display :0

/boot/config.txt
Uncomment: hdmi_force_hotplug=1 hdmi_group=2 hdmi_mode=16


* `sudo apt-get install netatalk git tightvncserver`
* `curl https://processing.org/download/install-arm.sh | sudo sh`
* `cd /home/pi && git clone https://github.com/scanlime/fadecandy.git`
* `cd /home/pi && git clone https://github.com/zzolo/aurora-shanty.git && cd aurora-shanty`
* FCServer startup
    * `sudo cp ./deploy/fcserver.conf /etc/init.d/fcserver && sudo chmod +x /etc/init.d/fcserver`
    * `sudo /etc/init.d/fcserver start`
    * `sudo update-rc.d fcserver defaults`
* VNC setup.  This is needed so Processing thinks there is a screen.  How this is setup requires that a user does this and is logged in.  [Reference](https://learn.adafruit.com/adafruit-raspberry-pi-lesson-7-remote-control-with-vnc/)
    * Run once to setup password: `vncserver :1`
* Processing sketch
    * Add to cron: `@reboot $HOME/.profile; /home/pi/aurora-shanty/deploy/aurora.sh > /home/pi/aurora.log 2>&1`


## Notes/links

* [FadeCandy Server config docs](https://github.com/scanlime/fadecandy/blob/master/doc/fc_server_config.md)
* [LED curtain example config](https://learn.adafruit.com/1500-neopixel-led-curtain-with-raspberry-pi-fadecandy/fadecandy-server-setup)
* [LED curtain processing example](https://learn.adafruit.com/1500-neopixel-led-curtain-with-raspberry-pi-fadecandy/dry-run)
* [Processing OPC docs](https://github.com/scanlime/fadecandy/blob/master/doc/processing_opc_client.md)

```
wget https://github.com/scanlime/fadecandy/archive/fcserver-1.04.zip && unzip fcserver-1.04.zip -d fcserver;
./fcserver/fadecandy-fcserver-1.04/bin/fcserver-osx
```

```
./fcserver/fadecandy-fcserver-1.04/bin/fcserver-osx ./fcserver-conf.json
```

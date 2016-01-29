# Aurora Shanty

Code and documentation for the [Aurora Shanty](http://aurora-shanty.tumblr.com/).

## Raspberry Pi deploy

* Get [Raspbian](https://www.raspberrypi.org/downloads/raspbian/)
* Update settings
    * Boot to CLI
    * Enable I2C
* (optional) [WiFi setup](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md)
* (optional) [Mausberry power switch](http://mausberry-circuits.myshopify.com/pages/setup)
* `sudo apt-get update && sudo apt-get upgrade`
* `sudo apt-get install netatalk git upstart default-jdk`

* `curl https://processing.org/download/install-arm.sh | sudo sh`

* `cd /home/pi && git clone https://github.com/scanlime/fadecandy.git`
* `cd /home/pi && git clone https://github.com/zzolo/aurora-shanty.git && cd aurora-shanty`
* `sudo cp ./deploy/fcserver.conf /etc/init/fcserver.conf`


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

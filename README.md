
# nomadic
![Overview](http://www.plantuml.com/plantuml/png/JO-n3e8m48PtdkB2xe89SJ8i9WwYH4oC8HqEQ8G0jXxNWHZVtLQiOVo_VdVtDnaPYStG1ngh3kyImdI2ewhb6C8hWCAcNPPleZY6AtBL25XjeTYRKioFPnnrAOaco5guODbBNYZl_reRl_iQPkr6XoV_n9ioD5zS-g77leZBhiewWimA93mxe6Qb1VXywckmKvs3dkK34aFQ4YboLnBvgEsdFm00)
## One Protocol on *anything*

### Installation
```
git clone https://github.com/xorgnak/urban-invention
cd urban-invention
chmod +x build.sh
./build.sh
```

- The `nomadic` tool can be run at boot as a cronjob.
- nomaic can be run locally to provide the tools to the nodes on a local area network.

### Nodes
The node.ino file should be flashed to any compatible ESP8266 or ESP32 microcontroller.  Once flashed, updates can be made through the ui at 192.168.0.1 once connected to the **esp8266** access point.  Once Your local ssid and password are set, you can set the accesspoint name and password to extend the local wifi network.  Extended firmware is available to interface your esp microcontroller with neopixel leds, oled screens, and other sensors and paripherals.

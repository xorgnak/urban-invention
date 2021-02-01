
# IoT from the microcontroller to the cloud
![Overview](http://www.plantuml.com/plantuml/png/JO-n3e8m48PtdkB2xe89SJ8i9WwYH4oC8HqEQ8G0jXxNWHZVtLQiOVo_VdVtDnaPYStG1ngh3kyImdI2ewhb6C8hWCAcNPPleZY6AtBL25XjeTYRKioFPnnrAOaco5guODbBNYZl_reRl_iQPkr6XoV_n9ioD5zS-g77leZBhiewWimA93mxe6Qb1VXywckmKvs3dkK34aFQ4YboLnBvgEsdFm00)

# hubs

Installing nomadic on running linux system will install the nomadic [toolkit](/TOOLS.md) and install the nomadic server to the system.  By Default, running `nomadic` will start the nomadic [server](/SERVER.md) and begin an interactive nomadic [shell](/SHELL.md) session to dirtectly interact with your server.

# Nodes

The node.ino file should be flashed to any compatible ESP8266 or ESP32 microcontroller.  Once flashed, updates can be made through the ui at 192.168.0.1 once connected to the **esp8266** access point.  Once Your local ssid and password are set, you can set the accesspoint name and password to extend the local wifi network.  Extended firmware is available to interface your esp microcontroller with neopixel leds, oled screens, and other sensors and paripherals.

# Installation

```
git clone https://github.com/xorgnak/urban-invention
cd urban-invention
chmod +x build.sh
./build.sh
```

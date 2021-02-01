
# nomadic
![Overview](http://www.plantuml.com/plantuml/png/LT31QiCm30RWkvz2zDu-G0-bi0x6sDgo1iQEIgob1YSsifoHjryiXurUWW9VzF_HCGcovC4R6iN939lt6Mu3ii0dIdVV0AOw_O6la1dUdazmnPvOWKwc2zvJ9owCITTS7JJOUX8rTNn4THL62L5D7HzDSoTuyY5R5Izk8jDpo15kD5fulLtEI_pi0rgZFM6xFIY3FT3GahLamTBaEW8t2Z7dA3jJwy2_ZHnwffJAsm-r66Fbg4LsO9QuDVb4Vb4Cvo3kstLO05m-e67NbqEKZLgZ_W_iI_D4NBwXYKRPhUHGBrV1sh7cQTfnUUJ1_m80)
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

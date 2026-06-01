# WIESEL Mini Wiring

## Main Connections

ESP32 to PCA9685:

```text
ESP32 3V3 or 5V -> PCA9685 VCC
ESP32 GND       -> PCA9685 GND
ESP32 GPIO 21   -> PCA9685 SDA
ESP32 GPIO 22   -> PCA9685 SCL
```

Servo power:

```text
5V power supply + -> PCA9685 V+
5V power supply - -> PCA9685 GND
PCA9685 GND       -> ESP32 GND
```

Important:

```text
The ESP32 and servo power supply must share GND.
Do not power servos from the ESP32 5V pin.
```

## Suggested Servo Channels

```text
PCA9685 channel 0 -> base servo
PCA9685 channel 1 -> shoulder servo
PCA9685 channel 2 -> elbow servo
PCA9685 channel 3 -> gripper servo
```

## Status LEDs

Suggested pins:

```text
GPIO 25 -> green LED
GPIO 26 -> yellow LED
GPIO 27 -> red LED
```

Use a resistor in series with each LED.

## Emergency Button

Suggested pin:

```text
GPIO 33 -> emergency input
```

Use proper pull-up or pull-down logic in the firmware.

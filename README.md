# BLE-Controlled-RC-Car

## Project Overview
This project demonstrates a four-wheel remote-controlled car using an ESP32-S3-DevKitM-1 as its core. The vehicle is controlled remotely via Bluetooth Low Energy (BLE) using a custom mobile application, showcasing a practical application of IoT and remote control technology.

## Key Components
- Microcontroller: ESP32-S3-DevKitM-1
- Motor Driver: L298N motor driver module
- Motors: Four DC geared motors
- Power Supply: Six 1.5V batteries (9V total)
- Connectivity: Bluetooth Low Energy (BLE)
- Control Interface: Custom mobile app

## Principles and Methodology
The system is built on a simple hardware-software architecture. The ESP32-S3 serves as the central processing unit, handling wireless communication and command decoding. The L298N module translates the ESP32's digital signals into motor movements, controlling the speed and direction of the car. The entire system is powered by a series of batteries, providing a stable voltage for the motors.

### The control process is straightforward:
1. A user sends a command (e.g., "move forward") from the mobile app.
2. The command is transmitted to the ESP32 via BLE.
3. The ESP32 decodes the command and sends a corresponding signal to the L298N driver.
4. The L298N adjusts the power to the motors, causing the car to move as instructed.

## Implementation Process
1. Hardware Assembly: All components were physically connected and configured to ensure proper operation.
2. Software Development: The code for the ESP32 was written to manage BLE communication and control logic. The mobile app was also developed to provide the user interface.
3. Testing and Debugging: The entire system was rigorously tested to ensure the car responded correctly and reliably to all commands.

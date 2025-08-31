# BLE Controlled RC Car
This repository contains the full code for a four-wheel remote-controlled car that is controlled via Bluetooth Low Energy (BLE) using a custom mobile application. The project is an excellent example of combining embedded systems (ESP32-S3) with mobile application development (SwiftUI) to create an IoT-based remote-controlled device.

## Project Components
This project consists of two main parts: the embedded system (car) and the mobile application (controller).

### 1. Embedded System (Arduino Code)
The Arduino code runs on the ESP32-S3-DevKitM-1, serving as the car's brain. It handles the following functions:
- BLE Communication: It acts as a BLE peripheral, advertising a specific service and characteristics to which a mobile device can connect.
- Motor Control: It uses an L298N motor driver to control the speed and direction of four DC geared motors.
- Command Interpretation: It receives integer commands (0-4) from the mobile app and translates them into motor actions (Forward, Backward, Left, Right, Stop).

### 2. Mobile Application (SwiftUI Code)
The Swift code is a mobile application developed with SwiftUI for iOS. It acts as the remote controller for the car. The application's main features include:
- BLE Management: It scans for and connects to the ESP32's BLE service.
- User Interface: It provides a simple, intuitive interface with directional buttons to control the car.
- Signal Transmission: When a user presses a button, the app sends a corresponding integer command to the ESP32 via a BLE characteristic.

## How It Works
The system operates on a client-server model over Bluetooth. The ESP32 is the server, waiting for a connection and commands. The mobile app is the client, which connects to the ESP32 and sends control signals.

When a button is pressed on the app, a specific integer (e.g., 0 for forward) is sent. The ESP32's `onWrite` callback function receives this integer and calls the appropriate motor control function (`forward()`, `backward()`, etc.), causing the car to move. The `loop()` function continuously checks for new commands to ensure immediate and responsive control.

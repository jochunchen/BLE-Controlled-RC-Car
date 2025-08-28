#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// BLE UUID
#define SERVICE_UUID           "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID_RX "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define CHARACTERISTIC_UUID_TX "129984f6-aca1-47b9-8e00-6ddb7b843923"

// L298N PIN
#define IN1 6
#define IN2 7
#define ENA 14
#define IN3 8
#define IN4 9
#define ENB 15

// Control command
#define FORWARD  0
#define BACKWARD 1
#define LEFT     2
#define RIGHT    3
#define STOP     4


BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic_RX = NULL;
BLECharacteristic* pCharacteristic_TX = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;
int cmd = -1;
int counter = 1;

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      Serial.println("Device Connected!");
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      Serial.println("Device Disconnected!");
    }
};

class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    std::string command = pCharacteristic->getValue();
    if (command.length() > 0) {
      Serial.println("====START=RECEIVE====");
      String cmd_string = String(command.c_str());
      cmd = cmd_string.toInt();
      Serial.println("Incoming command: " + String(cmd));
      Serial.println("====END=RECEIVE====");
    }
  }
};


void setup() {
  Serial.begin(115200);

  // L298N motor setup
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);
  pinMode(ENA, OUTPUT);
  pinMode(ENB, OUTPUT);

  // Create the BLE Device
  BLEDevice::init("ESP32_BLE!");

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE TX Characteristic
  pCharacteristic_TX = pService->createCharacteristic(
                      CHARACTERISTIC_UUID_TX,
                      BLECharacteristic::PROPERTY_NOTIFY);
  // Create a BLE Descriptor
  pCharacteristic_TX->addDescriptor(new BLE2902());

  // Create a BLE RX Characteristic
  pCharacteristic_RX = pService->createCharacteristic(
                      CHARACTERISTIC_UUID_RX,
                      BLECharacteristic::PROPERTY_WRITE);
                      
  pCharacteristic_RX->addDescriptor(new BLE2902());

  // Set callbacks of the characteristic
  pCharacteristic_RX->setCallbacks(new MyCallbacks);

  // Start the service
  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);  // set value to 0x00 to not advertise this parameter
  BLEDevice::startAdvertising();
  Serial.println("Waiting a client connection to notify...");
}

void loop() {    
    // disconnecting
    if (!deviceConnected && oldDeviceConnected) {
        delay(500); // give the bluetooth stack the chance to get things ready
        pServer->startAdvertising(); // restart advertising
        Serial.println("start advertising");
        oldDeviceConnected = deviceConnected;
    }
    
    // connecting
    if (deviceConnected && !oldDeviceConnected) {
        // do stuff here on connecting
        oldDeviceConnected = deviceConnected;
    }

    // RC car control
    if (cmd == FORWARD) {
      forward();  // Forward
    }
    else if (cmd == BACKWARD) {
      backward();  // Backward
    }
    else if (cmd == LEFT) {
      left();
    }
    else if (cmd == RIGHT) {
      right();
    }
    else if (cmd == STOP) {
      stopping();
    }
    
    // Obstacle avoidence
}

// Function for control L298N
void forward() {
  Serial.println("Forwarding");
  analogWrite(ENA, 150);
  analogWrite(ENB, 150);
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);
  delay(30);
  //cmd = -1;
  counter = 0;
}

void backward() {
  Serial.println("Backwarding");
  analogWrite(ENA, 150);
  analogWrite(ENB, 150);
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);
  delay(30);
  //cmd = -1;
  counter = 0;
}

void left() {
  Serial.println("left");
  analogWrite(ENA, 200);
  analogWrite(ENB, 200);
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);
  delay(30);
  //cmd = -1;
  counter = 0;
}

void right() {
  Serial.println("right");
  analogWrite(ENA, 200);
  analogWrite(ENB, 200);
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
  delay(30);
  //cmd = -1;
  counter = 0;
}

void stopping() {
  Serial.println("stop");
  digitalWrite(ENA, LOW);
  digitalWrite(ENB, LOW);
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
  delay(100);
}

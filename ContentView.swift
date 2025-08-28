import SwiftUI
import CoreBluetooth
import Combine


// Responsible for managing Bluetooth Low Energy (BLE) communication in the SwiftUI app
class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    // Published properties to observe changes
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var BLEconnected = false
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?

    // Bluetooth service and characteristic UUIDs
    let SERVICE_UUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")
    let CHARACTERISTIC_UUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")

    // Initialize central manager on class instantiation
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // Handle Bluetooth state updates
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            scanForDevices()
        } else {
            print("Bluetooth is not available.")
        }
    }

    // Start scanning for BLE devices
    func scanForDevices() {
        discoveredDevices = [] // Clear previous discoveries
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    // Handle discovered peripherals
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !discoveredDevices.contains(peripheral) {
            discoveredDevices.append(peripheral)
        }
    }

    // Handle successful connection to a peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        BLEconnected = true
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([SERVICE_UUID])
    }

    // Discover services for the connected peripheral
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == SERVICE_UUID {
                    peripheral.discoverCharacteristics([CHARACTERISTIC_UUID], for: service)
                    return
                }
            }
        }
    }

    // Send a signal to the connected peripheral
    func sendSignal(_ signal: String) {
        guard let peripheral = connectedPeripheral else {
            print("No connected peripheral.")
            return
        }

        guard let characteristic = findCharacteristic(for: CHARACTERISTIC_UUID, in: peripheral) else {
            print("Characteristic not found.")
            return
        }

        let data = signal.data(using: .utf8)
        peripheral.writeValue(data!, for: characteristic, type: .withResponse)
    }

    // Helper function to find a characteristic by UUID
    private func findCharacteristic(for uuid: CBUUID, in peripheral: CBPeripheral) -> CBCharacteristic? {
        for service in peripheral.services ?? [] {
            for characteristic in service.characteristics ?? [] {
                if characteristic.uuid == uuid {
                    return characteristic
                }
            }
        }
        return nil
    }
}


// Details of a Bluetooth Low Energy (BLE) device
class BLEDeviceDetailsViewModel: NSObject, ObservableObject, CBPeripheralDelegate {
    @Published var rssi: Int?

    // Handle RSSI reading from the connected peripheral
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        guard error == nil else {
            print("Failed to read RSSI: \(error!.localizedDescription)")
            return
        }

        rssi = RSSI.intValue
    }
}


// Displaying details of a Bluetooth Low Energy (BLE) device
struct BLEDeviceDetailsView: View {
    @StateObject private var viewModel = BLEDeviceDetailsViewModel()
    var peripheral: CBPeripheral
    
    var body: some View {
        VStack {
            // Display device details including RSSI
            Text("Device Details")
                .font(.title)
                .padding()

            Text("Device Name: \(peripheral.name ?? "Unknown")")
                .padding()

            Text("RSSI: \(viewModel.rssi ?? 0)")
                .padding()

            Spacer()
        }
        .padding()
        .onAppear {
            readRSSI()
        }
    }

    // Trigger RSSI reading on view appearance
    private func readRSSI() {
        guard peripheral.state == .connected else {
            print("Peripheral is not connected.")
            return
        }

        peripheral.delegate = viewModel
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            peripheral.readRSSI()
        }
    }
}


// Managing and displaying a Bluetooth Low Energy (BLE) device scanning interface
struct BLEScannerView: View {
    @ObservedObject var bleManager = BLEManager()
    @State private var selectedPeripheral: CBPeripheral?

    var body: some View {
        NavigationView {
            VStack {
                Text("BLE Scanner")
                    .font(.title)
                    .padding()

                // List of discovered BLE devices
                List(bleManager.discoveredDevices, id: \.identifier) { device in
                    NavigationLink(destination: BLEDeviceDetailsView(peripheral: device)) {
                        Text(device.name ?? "Unknown Device")
                            .onTapGesture {
                                selectedPeripheral = device
                                readRSSI(for: device)
                            }
                    }
                }
                .padding()

                // Button to initiate device scanning
                Button(action: {
                    bleManager.scanForDevices()
                }) {
                    Text("Scan for Devices")
                }
                .padding()
            }
            .onAppear {
                bleManager.centralManagerDidUpdateState(bleManager.centralManager)
            }
        }
    }

    // Connect to a peripheral and read its RSSI
    private func readRSSI(for peripheral: CBPeripheral) {
        bleManager.centralManager.connect(peripheral, options: nil)
        peripheral.readRSSI()
    }
}


// Presenting the main user interface of the application
struct ContentView: View {
    @State private var isPressed = false
    @State private var selectedDirection: ArrowDirection?
    @State private var signalText: String?

    @ObservedObject private var bleManager = BLEManager()

    var body: some View {
        NavigationView {
            VStack {
                bluetoothButton()

                Spacer().frame(height: 100)

                // Display arrow buttons for different directions
                HStack {
                    Spacer()
                    arrowButton(for: .forward)
                    Spacer()
                }

                HStack {
                    Spacer().frame(width: 30)
                    arrowButton(for: .left)
                    Spacer()
                    arrowButton(for: .right)
                    Spacer().frame(width: 30)
                }

                HStack {
                    Spacer()
                    arrowButton(for: .backward)
                    Spacer()
                }

                HStack {
                    Spacer()
                    arrowButton(for: .stop)
                }
            }
            .padding()
        }
    }

    // Create an arrow button with gesture recognizers
    private func arrowButton(for direction: ArrowDirection) -> some View {
        let imageName: String

        switch direction {
        case .forward:
            imageName = "arrow.up.circle.fill"
        case .backward:
            imageName = "arrow.down.circle.fill"
        case .left:
            imageName = "arrow.left.circle.fill"
        case .right:
            imageName = "arrow.right.circle.fill"
        case .stop:
            imageName = "stop.circle.fill"
        }

        return Image(systemName: imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        self.isPressed = true
                        self.selectedDirection = direction
                        self.signalText = "Signal for direction: \(direction.rawValue)"
                        sendSignal(for: direction)
                    }
                    .onEnded { _ in
                        self.isPressed = false
                        self.signalText = nil
                    }
            )
            .foregroundColor(isPressed && selectedDirection == direction ? .blue : .black)
    }

    // Create a button to navigate to BLE Scanner view
    private func bluetoothButton() -> some View {
        VStack {
            NavigationLink(destination: BLEScannerView(bleManager: bleManager)) {
                Image("Bluetooth")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
        }
    }

    // Send a signal based on the selected arrow direction
    private func sendSignal(for direction: ArrowDirection) {
        let signal = "\(direction.rawValue)"
        bleManager.sendSignal(signal)
    }
}


// A live preview of the ContentView in Xcode's canvas or the SwiftUI preview pane
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


enum ArrowDirection: Int {
    case forward = 0, backward = 1, left = 2, right = 3, stop = 4
}

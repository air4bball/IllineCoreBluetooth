//
//  StrongestPeripheralCentralManager.swift
//  CoreBluetoothTest
//
//  Created by Srikar on 11/4/23.
//

import Foundation
import CoreBluetooth
import UIKit

class CentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!

    var previousDevice: String = ""
    
    private var numConnections = 0
    var strongestPeripheral: MyCBPeripheral? = nil
    
    init(prevDevice: String) {
        previousDevice = prevDevice
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (centralManager.state == .poweredOn) {
            scanForPeripherals()
            if (MyVariables.numPeople == 1) {
                startPeriodicScanning()
            } else {
                scanForPeripherals()
            }
        }
    }
    
    private func startPeriodicScanning() {
        // Adjust the interval according to your needs
        let scanInterval = 10.0  // seconds
        Timer.scheduledTimer(timeInterval: scanInterval, target: self, selector: #selector(scanForPeripherals), userInfo: nil, repeats: true)
    }

    @objc func scanForPeripherals() {
        let serviceUUID = CBUUID(string: "7F37D5EB-05A3-4662-8357-5AA2DB93478F")
        print("scanning")
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (RSSI.intValue > strongestPeripheral?.getRSSI() ?? -100
            && peripheral.identifier != strongestPeripheral?.peripheral.identifier) {
            if let nextDevice = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
                if (previousDevice != nextDevice) {
                    print("connected")
                    strongestPeripheral = MyCBPeripheral(peripheral: peripheral, RSSI: RSSI)
                    numConnections = numConnections + 1
                }
            } else {
                print("Device mac identifier couldn't be converted to String or is nil.")
            }
        } else {
            return
        }

        if (numConnections > 5) {
            numConnections = 0
            central.stopScan()
            central.connect(strongestPeripheral!.peripheral, options: nil)
        } else {
            numConnections = 0
            if (strongestPeripheral != nil) {
                central.stopScan()
                central.connect(strongestPeripheral!.peripheral, options: nil)
            } else {
                print(MyVariables.numPeople)
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected \(peripheral.state == .connected)")
        peripheral.delegate = self
        let serviceUUID = CBUUID(string: "7F37D5EB-05A3-4662-8357-5AA2DB93478F")
        peripheral.discoverServices([serviceUUID])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("discovered services")
        if let services = peripheral.services {
            for service in services {
                let characteristicUUID = CBUUID(string: "A48A4D9C-FDA4-46F8-944E-30E9BE5B72C3")
                peripheral.discoverCharacteristics([characteristicUUID], for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("discovered characteristics for services in \(peripheral.identifier)")
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID(string: "A48A4D9C-FDA4-46F8-944E-30E9BE5B72C3") {
                    if let stringValue =
                        "\(MyVariables.numPeople + 1) \(String(describing: getDeviceIdentifier()))".data(using: .utf8) {
                        peripheral.writeValue(stringValue, for: characteristic, type: .withResponse)
                    }
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing value: \(error.localizedDescription)")
        } else {
            print("Write operation successful")
            // Continue with your logic, e.g., initiate further actions
        }
        centralManager.cancelPeripheralConnection(peripheral)
    }

    func getDeviceIdentifier() -> String? {
        if let macAddress = UIDevice.current.identifierForVendor?.uuidString {
            // Use the MAC address as the device identifier
            return macAddress
        } else {
            // Handle the case where obtaining the MAC address is not possible
            return nil
        }
    }
}

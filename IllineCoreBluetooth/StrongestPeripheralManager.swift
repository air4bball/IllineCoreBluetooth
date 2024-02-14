//
//  StrongestPeripheralManager.swift
//  CoreBluetoothTest
//
//  Created by Srikar on 11/22/23.
//

import Foundation
import CoreBluetooth
import UIKit

class StrongestPeripheralManager: NSObject, CBPeripheralManagerDelegate {
    var peripheralManager: CBPeripheralManager!
    var transferCharacteristic: CBMutableCharacteristic!
    var transferService: CBMutableService!
    let serviceUUID = CBUUID(string: "7F37D5EB-05A3-4662-8357-5AA2DB93478F")
    
    weak var delegate: LabelUpdateDelegate?
    
    override init() {
        super.init()
        
        let characteristicUUID = CBUUID(string: "A48A4D9C-FDA4-46F8-944E-30E9BE5B72C3")
        transferCharacteristic = CBMutableCharacteristic(
            type: characteristicUUID,
            properties: [.read, .write],
            value: nil,
            permissions: [.readable, .writeable]
        )

        // Create a service and add the characteristic to it
        transferService = CBMutableService(type: serviceUUID, primary: true)
        transferService.characteristics = [transferCharacteristic]
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheralManager.state == .poweredOn {
            peripheralManager.delegate = self
            let localName = getDeviceIdentifier() ?? ""
            let advertisingData: [String: Any] = [
                CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
                CBAdvertisementDataLocalNameKey: localName
            ]
            peripheralManager.add(transferService)
            peripheralManager.startAdvertising(advertisingData)
            print("is advertising \(peripheral.isAdvertising), \(peripheralManager.isAdvertising)")
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if request.characteristic == transferCharacteristic {
                if let value = request.value {
                    // Handle the received data
                    print("updating position")
                    handleReceivedData(value)
                    peripheralManager.stopAdvertising()
                    peripheralManager.respond(to: request, withResult: .success)
                } else {
                    peripheralManager.respond(to: request, withResult: .attributeNotFound)
                }
            }
        }
    }

    func handleReceivedData(_ data: Data) {
        let stringValue = String(data: data, encoding: .utf8) ?? ""
        let stringValueArr = stringValue.components(separatedBy: " ")
        let receivedInt = Int(stringValueArr[0])
        let previousDevice = stringValueArr[1]
        MyVariables.numPeople = receivedInt ?? 1
        print(MyVariables.numPeople)
        delegate?.updateLabel(withText: String(MyVariables.numPeople))
        _ = CentralManager(prevDevice: previousDevice)
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

//    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didDisconnectPeripheral error: Error?) {
//        MyVariables.numPeople = MyVariables.numPeople - 1
//    }

}

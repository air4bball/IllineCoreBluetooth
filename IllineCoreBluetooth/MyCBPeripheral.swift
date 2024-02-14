//
//  MyCBPeripheral.swift
//  CoreBluetoothTest
//
//  Created by Srikar on 11/4/23.
//

import Foundation
import CoreBluetooth

class MyCBPeripheral: NSObject, CBPeripheralDelegate {
    var peripheral: CBPeripheral!
    var RSSI: NSNumber
    
    init(peripheral: CBPeripheral, RSSI: NSNumber) {
        //super.init()
        self.peripheral = peripheral
        self.RSSI = RSSI
    }
    
    func getRSSI() -> Int {
        return RSSI.intValue
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Optionally, perform any other actions or communication with peripherals here
    }
}


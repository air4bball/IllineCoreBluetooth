//
//  ViewController.swift
//  CoreBluetoothTest
//
//  Created by Srikar on 11/4/23.
//

import UIKit
import CoreBluetooth

protocol LabelUpdateDelegate: AnyObject {
    func updateLabel(withText text: String)
}


class ViewController: UIViewController, LabelUpdateDelegate {
    
    @IBOutlet weak var display: UILabel!
    private var centralManager: CentralManager!
    private var peripheralManager: StrongestPeripheralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheralManager = StrongestPeripheralManager()
        peripheralManager.delegate = self
        updateLabel(withText: String(MyVariables.numPeople))
    }
    
    @IBAction func centralClicked(_ sender: Any) {
        centralManager = CentralManager(prevDevice: "")
    }
    
    func updateLabel(withText text: String) {
        self.display.text = "Your position in line: " + text
        print(MyVariables.numPeople)
    }
}
    

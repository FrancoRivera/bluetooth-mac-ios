//
//  ViewController.swift
//  BluetoothPOC
//
//  Created by Franco Rivera on 5/15/19.
//  Copyright © 2019 WeMake. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreMotion


class ViewController: UIViewController {
    // BLE Peripheral
    var BLEPeripheral: PeripheralBLE = PeripheralBLE()
    
    var timer = Timer()
    
    @IBOutlet weak var charactericDataLabel: UILabel!
    @IBOutlet weak var myPositionLabel: UILabel!
    @IBOutlet weak var myAccelerationLabel: UILabel!
    @IBAction func togglePeripheralAction(_ sender: UIButton) {
        //send random data
        
        if (sender.titleLabel?.text == "Stop Sending Data"){
            sender.setTitle("Start Sending Data", for: .normal)
            BLEPeripheral.manager.stopAdvertising()
        }
        else{
            sender.setTitle("Stop Sending Data", for: .normal)
            let dict: [String: Any] = [  CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: "2A3D")],
                                         CBAdvertisementDataLocalNameKey: "BluetoothPOC"]
            
            BLEPeripheral.manager.startAdvertising(dict)
        }

       
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
//        // Refactor this otherwise this wont work
//        self.myPositionLabel.text = "x: \(x.rounded(toPlaces: 6)) \ny: \(y.rounded(toPlaces: 6))\nz: \(z.rounded(toPlaces: 6))"
//
//        self.myAccelerationLabel.text = "x: \(acc_x.rounded(toPlaces: 6)) \ny: \(acc_y.rounded(toPlaces: 6))\nz: \(acc_z.rounded(toPlaces: 6))"
        }
}



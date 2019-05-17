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
    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!
    var manager: CBPeripheralManager!
    var myStringService: CBMutableService!
    var myStringCharacteristic: CBMutableCharacteristic!
    let stringCBUUID = CBUUID(string: "2A3D")
    var counter = 0
    var remotePeripheral: CBPeripheral!
    //manager
    var motionManager: CMMotionManager!
    
    var timer = Timer()
    
    @IBOutlet weak var charactericDataLabel: UILabel!
    @IBAction func startPeripheralAction(_ sender: UIButton) {
        //send random data
        manager.updateValue(Data("for real\(counter)".utf8), for: myStringCharacteristic, onSubscribedCentrals: nil)
        counter += 1
        charactericDataLabel.text = String(bytes: myStringCharacteristic.value!, encoding: .utf8)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        centralManager.delegate = self
        
       manager = CBPeripheralManager(delegate: self, queue: nil)
        motionManager = CMMotionManager()
        startDeviceMotion()
            }


}
extension ViewController: CBPeripheralManagerDelegate{
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed to connect")
    }
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("Peripheral changed stated")
        if (peripheral.state == .poweredOn){
           
            myStringService = CBMutableService(type: stringCBUUID, primary: true)
            myStringCharacteristic = CBMutableCharacteristic(type: stringCBUUID, properties: .notify, value: nil, permissions: .readable)
            myStringService.characteristics = [myStringCharacteristic]
            manager.add(myStringService)

            print("peripheral is ON")
            
            // centralManager.periphr
            let dict: [String: Any] = [  CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: "2A3D")],
                                         CBAdvertisementDataLocalNameKey: "BluetoothPOC"]

            peripheral.startAdvertising(dict)
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("peripheral is advertising")
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("somenigga susbscribed")
        characteristic.willChangeValue(forKey: "value")
        print("characteristics \(characteristic)")
    }
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("Ready again for my subs")
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("Service added")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("i connects")
        remotePeripheral = peripheral
        remotePeripheral.writeValue(Data("xd".utf8), for: myStringCharacteristic, type: .withoutResponse)
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        peripheral.respond(to: request, withResult: .success)
    }
}
extension ViewController: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            //[heartRateServiceCBUUID]
            //centralManager.scanForPeripherals(withServices: nil)
        }
    }
}

extension ViewController{
    
    func startDeviceMotion() {
        if motionManager.isDeviceMotionAvailable {
            self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            self.motionManager.showsDeviceMovementDisplay = true
            self.motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical)
            var last_x: Double = 0
            // Configure a timer to fetch the motion data.
            self.timer = Timer(fire: Date(), interval: (1.0 / 60.0), repeats: true,
                               block: { (timer) in
                                if let data = self.motionManager.deviceMotion {
                                    // Get the attitude relative to the magnetic north reference frame.
                                    
//                                    let x = data.attitude.pitch
//                                    let y = data.attitude.roll
//                                    let z = data.attitude.yaw
                                    let x = data.gravity.x
                                    let y = data.gravity.y
                                    let z = data.gravity.z
                                    
                                    // Use the motion data in your app.
                                    let data = Data("{\"x\": \(x), \"y\": \(y), \"z\": \(z) }".utf8)
                                    self.manager.updateValue(data, for: self.myStringCharacteristic, onSubscribedCentrals: nil)
                                    
                                }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer, forMode: RunLoop.Mode.default)
        }
    }
}

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
    var dataPoints: [String] = []
    //manager
    var motionManager: CMMotionManager!
    
    var timer = Timer()
    
    @IBOutlet weak var charactericDataLabel: UILabel!
    @IBOutlet weak var myPositionLabel: UILabel!
    @IBOutlet weak var myAccelerationLabel: UILabel!
    @IBAction func togglePeripheralAction(_ sender: UIButton) {
        //send random data
        
        if (sender.titleLabel?.text == "Stop Sending Data"){
            sender.setTitle("Start Sending Data", for: .normal)
            manager.stopAdvertising()
        }
        else{
            sender.setTitle("Stop Sending Data", for: .normal)
            let dict: [String: Any] = [  CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: "2A3D")],
                                         CBAdvertisementDataLocalNameKey: "BluetoothPOC"]
            
            manager.startAdvertising(dict)
        }

       
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        centralManager.delegate = self
        
       manager = CBPeripheralManager(delegate: self, queue: nil)
        motionManager = CMMotionManager()
        startDeviceMotion()
        startSendDataWithInterval(miliseconds: 100)
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
    func startSendDataWithInterval(miliseconds: Double){
        Timer.scheduledTimer(withTimeInterval: 1*1000/60/1000, repeats: true, block: {_ in
            if(self.dataPoints.count > 0){
                var arrayData = "["
                for i in 0..<self.dataPoints.count{
                    arrayData.append(contentsOf: self.dataPoints[i] + ", ")
                }
                // delete last comma
                arrayData.remove(at: arrayData.index(before: arrayData.endIndex))
                arrayData.remove(at: arrayData.index(before: arrayData.endIndex))
                // append last bracket
                arrayData.append(contentsOf: "]")
                let data = Data(arrayData.utf8)
                self.dataPoints = []
            
                self.manager.updateValue(data, for: self.myStringCharacteristic, onSubscribedCentrals: nil)
                
            }
            
        })
        
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

//                 let x = data.attitude.pitch
//                 let y = data.attitude.roll
//                 let z = data.attitude.yaw
                    let acc_x = data.userAcceleration.x
                    let acc_y = data.userAcceleration.y
                    let acc_z = data.userAcceleration.z
                    let x = data.gravity.x
                    let y = data.gravity.y
                    let z = data.gravity.z
                    let rot_x = data.rotationRate.x
                    let rot_y = data.rotationRate.y
                    let rot_z = data.rotationRate.z
                    let mag_x = data.magneticField.field.x
                    let mag_y = data.magneticField.field.y
                    let mag_z = data.magneticField.field.z
                    
                    
                    // Use the motion data in your app.
                    self.dataPoints.append("{\"x\": \(x.rounded(toPlaces: 5)), \"y\": \(y.rounded(toPlaces: 5)), \"z\": \(z.rounded(toPlaces: 5)),"
                                        + " \"acc_x\": \(acc_x.rounded(toPlaces: 5)), \"acc_y\": \(acc_y.rounded(toPlaces: 5)), \"acc_z\": \(acc_z.rounded(toPlaces: 5)),"
                                        + " \"rot_x\": \(rot_x.rounded(toPlaces: 5)), \"rot_y\": \(rot_y.rounded(toPlaces: 5)), \"rot_z\": \(rot_z.rounded(toPlaces: 5))}")
                    
                    self.myPositionLabel.text = "x: \(x.rounded(toPlaces: 6)) \ny: \(y.rounded(toPlaces: 6))\nz: \(z.rounded(toPlaces: 6))"
                    
                    self.myAccelerationLabel.text = "x: \(acc_x.rounded(toPlaces: 6)) \ny: \(acc_y.rounded(toPlaces: 6))\nz: \(acc_z.rounded(toPlaces: 6))"
                    
                }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer, forMode: RunLoop.Mode.default)
        }
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

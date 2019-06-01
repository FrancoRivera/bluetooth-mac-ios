//
//  PeripheralBLE.swift
//  Bluetooth-Mac-iOS
//
//  Created by Franco Rivera on 5/23/19.
//  Copyright © 2019 WeMake. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreMotion

class PeripheralBLE: NSObject {
    
    // Attributes
    
    // Central Manager - Not Used
    var centralManager: CBCentralManager!
    
    // The peripheral of this device
    var myPeripheral: CBPeripheral!
    
    // This device's Peripheral Manager
    var manager: CBPeripheralManager!
    
    // The Service thats gonna hold the characteristic
    var myStringService: CBMutableService!
    
    // Where my characteristic is going to live
    var myStringCharacteristic: CBMutableCharacteristic!
    
    // Change this CBUIID to a stronger
    let stringCBUUID = CBUUID(string: "2A3D")
    
    // collect data points for
    var dataPoints: [String] = []
    
    // Mootion Manager
    var motionManager: CMMotionManager!
    
    // timer to send at Interval
    var timer = Timer()

    override init(){
        super.init()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        centralManager.delegate = self
        
        manager = CBPeripheralManager(delegate: self, queue: nil)
        motionManager = CMMotionManager()
        
        startDeviceMotion()
        
        // especify how often the data interval should be sent in miliseconds
        // set at 60hz by default (for performance change to 30hz)
        // packets will be sent at this inteval but the data flow will be
        // 60 data points per second regardless of this number
        startSendDataWithInterval(miliseconds: 1/60)
    }


}
extension PeripheralBLE: CBPeripheralManagerDelegate{
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
         // The peripheral State Changed
        print("Peripheral changed stated")
        switch peripheral.state{
            
        case .unknown:
            print("Peripheral is at an Uknown State")
        case .resetting:
              print("Peripheral is resetting")
        case .unsupported:
              print("Peripheral is unsupported")
        case .unauthorized:
              print("Peripheral is unauthorized")
        case .poweredOff:
              print("Peripheral is powered OFF")
        case .poweredOn:
                print("The Peripheral is powered ON")
                setCharacteristicsAndAdvertise(peripheral: peripheral)
        @unknown default:
              print("Unhandled State of Peripheral")
        }
    }
    
    func setCharacteristicsAndAdvertise(peripheral: CBPeripheralManager){
        
        // set up CB service
        myStringService = CBMutableService(type: stringCBUUID, primary: true)
        
        // Set up the characteristic, note that is a "notify" chracteristic with value nil.
        myStringCharacteristic = CBMutableCharacteristic(type: stringCBUUID, properties: .notify, value: nil, permissions: .readable)
        
        // add the cracteristic to the service
        myStringService.characteristics = [myStringCharacteristic]
        
        //add the service to the manager
        manager.add(myStringService)
        
        // sets up the adverstisement on the peripheral
        let nameOfPeripheral = "iPhone Bluetooth POC"
        let dict: [String: Any] = [  CBAdvertisementDataServiceUUIDsKey: [stringCBUUID],
                                     CBAdvertisementDataLocalNameKey: nameOfPeripheral]
        // starts advertisment
        // if the advertisment is successful it is caught on peripheralManagerDidStartAdvertising
        peripheral.startAdvertising(dict)
    }

    func startSendDataWithInterval(miliseconds: Double){
        Timer.scheduledTimer(withTimeInterval: miliseconds, repeats: true, block: {_ in
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
                
                // Inspect what is being sent
                //print(data)
                
                // update Value notifiies to suscribers that the value of chracteristic has changed
                self.manager.updateValue(data, for: self.myStringCharacteristic, onSubscribedCentrals: nil)
                
            }
            
        })
        
    }
    
    // debugging events mostly

    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("Peripheral is Now Advertising")
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("MTU: \(central.maximumUpdateValueLength) just susbscribed to characteristics \(characteristic)")
        print()
    }
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("Ready again for any subscribers")
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("Service was added succesfully")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        peripheral.respond(to: request, withResult: .success)
    }
    
}


extension PeripheralBLE{
    func startDeviceMotion() {
        if motionManager.isDeviceMotionAvailable {
            self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            self.motionManager.showsDeviceMovementDisplay = true
            self.motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical)
            // Configure a timer to fetch the motion data.
            
            // update every 60 hz
            self.timer = Timer(fire: Date(), interval: (1.0 / 60.0), repeats: true,
                               block: { (timer) in
                            if let data = self.motionManager.deviceMotion {
                                // Get the attitude relative to the magnetic north reference frame.
                                
                                // let x = data.attitude.pitch
                                // let y = data.attitude.roll
                                // let z = data.attitude.yaw
                                
                                // get acceleration in 3 axis
                                let acc = [ data.userAcceleration.x.rounded(toPlaces: 5),
                                            data.userAcceleration.y.rounded(toPlaces: 5),
                                            data.userAcceleration.z.rounded(toPlaces: 5)]
                                
                                // get gravity in 3 axis
                                let grav = [data.gravity.x.rounded(toPlaces: 5),
                                            data.gravity.y.rounded(toPlaces: 5),
                                            data.gravity.z.rounded(toPlaces: 5)]
                                
                                // get rotation rate in 3 axis
                                let rot  = [data.rotationRate.x.rounded(toPlaces: 5),
                                            data.rotationRate.y.rounded(toPlaces: 5),
                                            data.rotationRate.z.rounded(toPlaces: 5)]
                                
                                // get magnetic field in 3 axis
                                let mag  = [data.magneticField.field.x.rounded(toPlaces: 5),
                                            data.magneticField.field.y.rounded(toPlaces: 5),
                                            data.magneticField.field.z.rounded(toPlaces: 5)]
                                
                                
                                // Add motion data to dataPoints app.
                                var string = "{\"x\": \(grav[0]), \"y\": \(grav[1]), \"z\": \(grav[2]),"
                                string += " \"acc_x\": \(acc[0]), \"acc_y\": \(acc[1]), \"acc_z\": \(acc[2]),"
                                string += " \"rot_x\": \(rot[0]), \"rot_y\": \(rot[1]), \"rot_z\": \(rot[2]),"
                                string += " \"mag_x\": \(mag[0]), \"mag_y\": \(mag[1]), \"mag_z\": \(mag[2])"
                                string += "}"
                                self.dataPoints.append(string)
                            }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer, forMode: RunLoop.Mode.default)
        }
    }
}




// Utilities

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}




// Not used


// This is for the central manager, not used at the moment
extension PeripheralBLE: CBCentralManagerDelegate{
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
        @unknown default:
            print("Uknown State")
        }
    }
    // if the central fails to connect
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed to connect")
    }
}


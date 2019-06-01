//
//  InterfaceController.swift
//  Bluetooth-watch Extension
//
//  Created by Franco Rivera on 5/20/19.
//  Copyright © 2019 WeMake. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import CoreBluetooth


class InterfaceController: WKInterfaceController {
    
    // Motion Manager
    var motionManager: CMMotionManager!
    
    // collect data points for
    var dataPoints: [String] = []
    
    // Set Timer for CoreMotion
    var timer = Timer()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        motionManager = CMMotionManager()
        
        startDeviceMotion()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
extension InterfaceController{
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
                                    let acc = [ data.userAcceleration.x,
                                                data.userAcceleration.y,
                                                data.userAcceleration.z]
                                    
                                    // get gravity in 3 axis
                                    let grav = [data.gravity.x,
                                                data.gravity.y,
                                                data.gravity.z]
                                    
                                    // get rotation rate in 3 axis
                                    let rot  = [data.rotationRate.x,
                                                data.rotationRate.y,
                                                data.rotationRate.z]
                                    
                                    // get magnetic field in 3 axis
                                    let mag  = [data.magneticField.field.x,
                                                data.magneticField.field.y,
                                                data.magneticField.field.z]
                                    
                                    
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

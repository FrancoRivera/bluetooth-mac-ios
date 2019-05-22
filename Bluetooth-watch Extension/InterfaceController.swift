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

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        let manager = CMMotionManager()
        manager.accelerometerData?.acceleration.x
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

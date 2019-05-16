//
//  BluetoothDevices.swift
//  ExampleMacOSApp
//
//  Created by Franco Rivera on 5/15/19.
//  Copyright © 2019 WeMake. All rights reserved.
//

import Foundation

import IOBluetooth
import IOBluetoothUI

// See https://developer.apple.com/reference/iobluetooth/iobluetoothdevice
// for API details.
class BluetoothDevices: IOBluetoothDeviceInquiryDelegate {
    func pairedDevices() {
        print("Bluetooth devices:")
        guard let devices = IOBluetoothDevice.pairedDevices() else {
            print("No devices")
            return
        }
        for item in devices {
            if let device = item as? IOBluetoothDevice {
                print("Address: \(device.addressString)")
                print("Name: \(device.name)")
                print("Paired?: \(device.isPaired())")
                print("Connected?: \(device.isConnected())")
            }
        }
    }
    func discoverDevices(){
         print("Bluetooth discovery:")
        var device = IOBluetoothDevice()
        var chan: IOBluetoothRFCOMMChannel? = IOBluetoothRFCOMMChannel()
        var pointer = chan.self.self.self.self

    
        var notification: IOBluetoothUserNotification
        //notification = IOBluetoothDevice.registerForConnectNotifications(.class(), selector: "newConnection:fromDevice:")

//        var yolo = AutoreleasingUnsafeMutablePointer(&chan)!
//        var  roomChannelId = chan!.getID()
//        //var rfcom = moto.openRFCOMMChannelSync(yolo, withChannelID: roomChannelId, delegate: self)
        //if (rfcom == kIOReturnSuccess){
        //    print(" THIS WAS GOOD")
        //}
        //else{
        //    print("DAFUQ")
        //}
        //print(yolo.pointee?.isOpen())
        
    }
}


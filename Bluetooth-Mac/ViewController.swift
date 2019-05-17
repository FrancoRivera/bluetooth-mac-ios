//
//  ViewController.swift
//  ExampleMacOSApp
//
//  Created by Franco Rivera on 5/15/19.
//  Copyright © 2019 WeMake. All rights reserved.
//

import Cocoa

import IOBluetooth

class ViewController: NSViewController, IOBluetoothDeviceInquiryDelegate, IOBluetoothRFCOMMChannelDelegate{
    var inquiry: IOBluetoothDeviceInquiry?
    var devices: [IOBluetoothDevice] = []
    
    @IBOutlet weak var devicesTableView: NSTableView!
    @IBOutlet weak var searchDevicesButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up table view delegate
        
        devicesTableView.delegate = self
        devicesTableView.dataSource = self
        devicesTableView.target = self
        devicesTableView.doubleAction = #selector(tableViewDoubleClick(_:))
        
        // set up Bluetooth Devices
        let bt = BluetoothDevices()
        bt.discoverDevices()
        
        let r: IOReturn
        inquiry = IOBluetoothDeviceInquiry(delegate: self)
        inquiry!.start()
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    func deviceInquiryStarted(_ sender: IOBluetoothDeviceInquiry!) {
        print("Discovery Started Succesfuly")
        searchDevicesButton.title = "searching..."
        searchDevicesButton.state = .off
    }
    // gets called when devices is found
    func deviceInquiryDeviceFound(_ sender: IOBluetoothDeviceInquiry!, device: IOBluetoothDevice!) {
        // if devices is found append to list
        devices.append(device)
        devicesTableView.noteNumberOfRowsChanged()

    }
    // se llama cuando acaba el discovery
    func deviceInquiryComplete(_ sender: IOBluetoothDeviceInquiry!, error: IOReturn, aborted: Bool) {
        print("device inquiry ended")
        searchDevicesButton.title = "Search for devices"
        searchDevicesButton.state = .on
    }

    @IBAction func searchDevicesAction(_ sender: Any) {
        // empieza el discovery
        inquiry!.start()
    }
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        
        // check if item exists
        guard devicesTableView.selectedRow >= 0,
            let device = devices[devicesTableView.selectedRow] as IOBluetoothDevice? else {
                return
            }
        // connect to device
        if (!device.isPaired()){
            print("Emparejando")
            let pair = IOBluetoothDevicePair(device: device)
            pair?.start()
            pair?.delegate = self
        }
        if (!device.isConnected()){
            print("Conectandome a \(device.addressString!)")
            let r = device.openConnection()
            if (r == kIOReturnSuccess){
                print("Conectado satisfactoriamente")
            }
        }
        else{
            device.performSDPQuery(self)
            //print("Servicios:")
            //print(device.services)
            var chan:IOBluetoothRFCOMMChannel? = IOBluetoothRFCOMMChannel()
            var yolo = AutoreleasingUnsafeMutablePointer(&chan)!
            device.openRFCOMMChannelAsync(yolo, withChannelID: 1, delegate: self)
        }
    }
    func rfcommChannelOpenComplete(_ rfcommChannel: IOBluetoothRFCOMMChannel!, status error: IOReturn) {
        print("It opened mofo")
        print("MTU \(rfcommChannel.getMTU())")
        let str = "Hello"
        var buf: [UInt8] = Array(str.utf8)
        var swag = UnsafeMutableRawPointer(&buf)!
        let pointer = UnsafePointer(buf)
        
        rfcommChannel.writeAsync(swag, length: UInt16(buf.count), refcon: swag)
        
    }
    func rfcommChannelClosed(_ rfcommChannel: IOBluetoothRFCOMMChannel!) {
        print("RF COMM CLOSED")
    }
    func rfcommChannelWriteComplete(_ rfcommChannel: IOBluetoothRFCOMMChannel!,
                                             refcon: UnsafeMutableRawPointer!,
                                             status error: IOReturn){
        print(error)
        print("Data was sent succesfuly")
    }
    func rfcommChannelData(_ rfcommChannel: IOBluetoothRFCOMMChannel!, data dataPointer: UnsafeMutableRawPointer!, length dataLength: Int) {
        print("Some data was sent here")
    }
    func devicePairingPINCodeRequest(_ sender: Any!) {
        print("device")
    }
    
}


extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return devices.count
        
    }
    
}

extension ViewController: NSTableViewDelegate {
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        tableColumn?.title = "Dispositivos encontrados"
     
            //configura la celda
        if let cell = tableView.makeView(withIdentifier:  NSUserInterfaceItemIdentifier(rawValue: "myCellIdentifier"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = "\(devices[row].nameOrAddress!) -- \(devices[row].rssi())"
            return cell
        }
        return nil
    }
    func tableViewSelectionDidChange(_ notification: Notification) {
        let index = devicesTableView.selectedRow
    }
    
    
}

//
//  BLEViewController.swift
//  ExampleMacOSApp
//
//  Created by Franco Rivera on 5/16/19.
//  Copyright © 2019 WeMake. All rights reserved.
//

import Cocoa
import CoreBluetooth

class BLEViewController: NSViewController {
    var centralManager: CBCentralManager!
    var phonePeripheral: CBPeripheral!
    var devices: [CBPeripheral] = []
    
    let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
    let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")
    let stringCharacteristicCBUUID = CBUUID(string: "2A3D")
    let manufacturerNameStringCBUUID = CBUUID(string: "2A29")
    let modelNumberStringCBUUID = CBUUID(string: "2A24")
    var stringCBUUID = CBUUID(string:"2A3D")
    
    var pointDraw: MyView = MyView()
    
    @IBOutlet weak var devicesTableView: NSTableView!
    @IBOutlet weak var searchDevicesButton: NSButton!
    @IBAction func searchDevicesAction(_ sender: Any) {
        centralManager.stopScan()
        centralManager.scanForPeripherals(withServices: [stringCBUUID], options: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        // set up table view delegate
        
        devicesTableView.delegate = self
        devicesTableView.dataSource = self
        devicesTableView.target = self
        devicesTableView.doubleAction = #selector(tableViewDoubleClick(_:))
        

         self.view.addSubview(pointDraw)
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
}
extension BLEViewController: CBCentralManagerDelegate{
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
            centralManager.scanForPeripherals(withServices: [stringCBUUID])
            
            //centralManager.scanForPeripherals(withServices:nil)
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Connected to: \(peripheral.name)")
        
        phonePeripheral = peripheral
        phonePeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(phonePeripheral, options: nil)
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("It connencted fam")
        phonePeripheral.discoverServices([stringCBUUID])
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("this iant it fam")
    }
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            // Heart Rate Value Format is in the 2nd byte
            return Int(byteArray[1])
        } else {
            // Heart Rate Value Format is in the 2nd and 3rd bytes
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
}

extension BLEViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("services discovered for periferal")
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("subscribed to \(characteristic)")
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case stringCBUUID:
            // draw positionn
            drawPoint(point:String(bytes: characteristic.value ?? Data("no-data".utf8), encoding: .utf8) ?? "0.0")
            
        case manufacturerNameStringCBUUID, modelNumberStringCBUUID:
            print(String(bytes: characteristic.value!, encoding: .utf8) ?? "no value")
        default:
            print("Unhandled Characteristic UUID:  \(characteristic.uuid) - \(characteristic.uuid.uuidString)")
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("them services changed yo!")
        print(invalidatedServices)
    }
    func parseJson(jsonText: String) -> NSDictionary?{
        var dictonary:NSDictionary?
        
        if let data = jsonText.data(using: String.Encoding.utf8) {
            
            do {
                dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] as NSDictionary?
                
                if let myDictionary = dictonary
                {
                   return myDictionary
                }
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    func drawPoint(point: String){
        print(point)
        let json = parseJson(jsonText: point)
        pointDraw.frame =  CGRect(x: ((json!["x"] as! CGFloat) * self.view.frame.width/2 + self.view.frame.width/2), y: ((json!["y"] as! CGFloat) * self.view.frame.height/2 + self.view.frame.height/2), width: 3, height: 3)
       
    }
}
class MyView: NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // #1d161d
        NSColor(white: 1, alpha: 1).setFill()
        dirtyRect.fill()
    }
    
}







extension BLEViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return devices.count
        
    }
    
}

extension BLEViewController: NSTableViewDelegate {
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        tableColumn?.title = "Dispositivos encontrados"
        
        //configura la celda
        if let cell = tableView.makeView(withIdentifier:  NSUserInterfaceItemIdentifier(rawValue: "myCellIdentifier"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = "\(devices[row].name!) -- \(devices[row].rssi)"
            return cell
        }
        return nil
    }
    func tableViewSelectionDidChange(_ notification: Notification) {
        let index = devicesTableView.selectedRow
    }
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        
        // check if item exists
        guard devicesTableView.selectedRow >= 0,
            let device = devices[devicesTableView.selectedRow] as CBPeripheral? else {
                return
        }
        
        //this device
    }
    
}

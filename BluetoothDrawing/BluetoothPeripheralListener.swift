//
//  BluetoothCentralDataModel.swift
//  BluetoothDrawing
//
//  Created by Oleksii Nezhyborets on 14.12.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothPeripheralListener : NSObject {
    weak var delegate: DataModelDelegate?
    let connectedPeripheral : CBPeripheral
    fileprivate let serviceCBUUID : CBUUID
    fileprivate let characteristicID : CBUUID
    
    init(connectedPeripheral: CBPeripheral, serviceId: CBUUID, characteristicID: CBUUID) {
        self.connectedPeripheral = connectedPeripheral
        self.serviceCBUUID = serviceId
        self.characteristicID = characteristicID
        super.init()
    }
}

extension BluetoothPeripheralListener : DataModel {
    weak internal var dataDelegate: DataModelDelegate? {
        get {
            return delegate
        }
        set {
            delegate = newValue
        }
    }

    func write(dataJson json: [String : AnyObject]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let peripheral = connectedPeripheral
            var characteristic : CBCharacteristic!
            for service in peripheral.services! {
                for char in service.characteristics! {
                    if char.uuid == self.characteristicID {
                        print("Found Characteristic to write")
                        characteristic = char
                    }
                }
            }
            
            print("peripheral delegate \(peripheral.delegate)")
            
            if characteristic.properties.contains(.write) {
                // Responses are available, so write with response.
                peripheral.writeValue(data, for: characteristic, type: .withResponse)
            } else if characteristic.properties.contains(.writeWithoutResponse) {
                // Responses are not available.
                // Write with response is going to fail, so write without response.
                peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
            } else {
                fatalError()
            }
        } catch {
            precondition(false)
        }
    }
}

extension BluetoothPeripheralListener : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            //**************************
            //drawFromData(data: value)
            do {
                let json = try JSONSerialization.jsonObject(with: value, options: .allowFragments) as! [String : AnyObject]
                delegate?.didGet(newData: json, inModel: self)
            } catch {
                precondition(false)
            }
        }
    }
    
    //Why do we need all of the following methods?
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("did discover")
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {
            print("discovered service: \(service.debugDescription)")
            peripheral.discoverCharacteristics([characteristicID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("did discover Characteristics For Service \(service) ERROR \(error)")
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        } else {
            print("NO CHARACTERISTICS")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("NOTIFYING IS NOW \(characteristic.isNotifying) error \(error)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("did Write Characteristic error \(error)")
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("did Write descriptor error \(error)")
    }
}

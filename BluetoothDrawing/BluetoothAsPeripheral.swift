//
//  BluetoothAsPeripheralDataModel.swift
//  BluetoothDrawing
//
//  Created by Oleksii Nezhyborets on 15.12.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothAsPeripheral: NSObject, DataModel {
    fileprivate var connectedCentral : CBCentral?
    fileprivate let characteristic : CBMutableCharacteristic
    fileprivate let manager : CBPeripheralManager
    fileprivate let serviceID : CBUUID
    weak var dataDelegate: DataModelDelegate?
    weak var connectionDelegate: ConnectionProviderDelegate?
    
    init(manager: CBPeripheralManager, serviceID: CBUUID, characteristic: CBMutableCharacteristic) {
        self.characteristic = characteristic
        self.manager = manager
        self.serviceID = serviceID
        super.init()
    }
    
    func write(dataJson json: [String : AnyObject]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            if data.count > connectedCentral!.maximumUpdateValueLength {
                print("too big")
            }
            
            _ = manager.updateValue(data, for: characteristic, onSubscribedCentrals: nil)
        } catch {
            precondition(false)
        }
    }
}

extension BluetoothAsPeripheral : ConnectionProvider {
    var model: DataModel? {
        get {
            return self
        }
    }
    
    var state: ConnectionState {
        get {
            return .connected
        }
    }
}

extension BluetoothAsPeripheral : CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("Peripheral Did Update State")
        switch peripheral.state {
        case .unknown:
            print("unknown")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .resetting:
            print("resetting")
        case .poweredOff:
            print("poweredOff")
        case .poweredOn:
            print("poweredOn")
            let myService = CBMutableService(type: serviceID, primary: true)
            myService.characteristics = [characteristic]
            peripheral.add(myService)
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("peripheralManagerDidStartAdvertising \(peripheral) error \(error)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let uError = error {
            print("peripheralManager Error Adding service \(uError)")
        } else {
            print("peripheralManager didAdd service \(service.debugDescription)")
            manager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [serviceID]])
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        //we are using CBPeripheral setNotifyValue for reading data from peripheral
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        let request = requests.first!
        do {
            let json = try JSONSerialization.jsonObject(with: request.value!, options: []) as! [String : AnyObject]
            dataDelegate?.didGet(newData: json, inModel: self)
        } catch {
            precondition(false)
        }
        manager.respond(to: request, withResult: .success)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("peripheralManager didSubscribeTo characteristic \(characteristic)")
        connectedCentral = central
        connectionDelegate?.establishedConnection(withModel: self, connectionProvider: self)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("peripheralManager didUnsubscribeFrom characteristic \(characteristic)")
        connectedCentral = nil
        connectionDelegate?.didDisconnect(fromModel: self, withError: nil, connectionProvider: self)
    }
}

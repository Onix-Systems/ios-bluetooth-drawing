//
//  Bluetooth.swift
//  BluetoothDrawing
//
//  Created by Oleksii Nezhyborets on 13.12.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol PeripheralsListDelegate: class {
    func didUpdate(peripherals: [CBPeripheral])
}

struct Bluetooth {
    static let serviceCBUUID : CBUUID = {
        let serviceUUID = "0DC49429-202D-4767-970C-A8513C468A73"
        let serviceCBUUID = CBUUID(string: serviceUUID)
        return serviceCBUUID
    }()
    
    static let characteristicCBUUID : CBUUID = {
        return CBUUID(string: "01B70A85-7786-4520-B5AB-0185F6259F38")
    }()
    
    static let characteristic : CBMutableCharacteristic = {
        let myCharacteristic = CBMutableCharacteristic(type: characteristicCBUUID, properties: [.read, .notify, .writeWithoutResponse], value: nil, permissions: [CBAttributePermissions.readable, CBAttributePermissions.writeable])
        return myCharacteristic
    }()
    
    static func bluetoothAsPeripheral() -> BluetoothAsPeripheral {
        let manager = CBPeripheralManager(delegate: nil, queue: nil)
        let asPeripheral = BluetoothAsPeripheral(manager: manager, serviceID: serviceCBUUID, characteristic: characteristic)
        manager.delegate = asPeripheral
        return asPeripheral
    }
}

class BluetoothCentral : NSObject {
    weak var listDelegate : PeripheralsListDelegate?
    weak var connectionDelegate : ConnectionProviderDelegate?
    
    override init() {
        super.init()
        
        myCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func connect(peripheral: CBPeripheral) {
        connecting = true
        myCentralManager.connect(peripheral, options: nil)
    }
    
    func peripherals() -> [CBPeripheral] {
        return Array(peripheralsDict.values)
    }
    
    fileprivate var peripheralsDict : [UUID : CBPeripheral] = [:]
    fileprivate var myCentralManager : CBCentralManager! = nil
    fileprivate var peripheralListener : BluetoothPeripheralListener?
    fileprivate var connecting = false
}

extension BluetoothCentral : CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central didUpdateState")
        switch central.state {
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
            central.scanForPeripherals(withServices: [Bluetooth.serviceCBUUID], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("central didDiscover peripheral \(peripheral.debugDescription)")
        
        peripheralsDict[peripheral.identifier] = peripheral
        listDelegate?.didUpdate(peripherals: peripherals())
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect peripheral \(peripheral.debugDescription)")
        let bluetoothAsCentral = BluetoothPeripheralListener(connectedPeripheral: peripheral, serviceId: Bluetooth.serviceCBUUID, characteristicID: Bluetooth.characteristicCBUUID)
        peripheral.delegate = bluetoothAsCentral
        peripheral.discoverServices([Bluetooth.serviceCBUUID])
        peripheralListener = bluetoothAsCentral
        connectionDelegate?.establishedConnection(withModel: bluetoothAsCentral, connectionProvider: self)
        connecting = false
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connecting = false
        connectionDelegate?.didDisconnect(fromModel: peripheralListener!, withError: error, connectionProvider: self)
        peripheralListener = nil
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connecting = false
        connectionDelegate?.failedConnection(with: error!, inProvider: self)
    }
}

extension BluetoothCentral : ConnectionProvider {
    var model: DataModel? {
        get {
            return peripheralListener
        }
    }
    
    var state: ConnectionState {
        get {
            if peripheralListener != nil {
                return .connected
            } else if connecting {
                return .connecting
            } else {
                return .disconnected
            }
        }
    }
}

//
//  GameDataProvider.swift
//  BluetoothDrawing
//
//  Created by Oleksii Nezhyborets on 13.12.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

enum ConnectionState {
    case disconnected
    case connecting
    case connected
}

protocol DataModel {
    weak var dataDelegate : DataModelDelegate? {get set}
    func write(dataJson json: [String : AnyObject])
}

protocol DataModelDelegate: class {
    func didGet(newData json: [String : AnyObject], inModel model: DataModel)
}

protocol ConnectionProvider {
    var state : ConnectionState {get}
    var model : DataModel? {get}
}

protocol ConnectionProviderDelegate:class {
    func failedConnection(with error: Error, inProvider provider: ConnectionProvider)
    func didDisconnect(fromModel: DataModel, withError error: Error?, connectionProvider: ConnectionProvider)
    func establishedConnection(withModel: DataModel, connectionProvider: ConnectionProvider)
}

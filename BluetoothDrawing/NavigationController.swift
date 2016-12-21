//
//  NavigationController.swift
//  BluetoothDrawing
//
//  Created by Oleksii Nezhyborets on 19.12.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit
import CoreBluetooth

class NavigationController: UINavigationController {
    let bluetooth = BluetoothCentral()
    let bluetoothAsPeripheral = Bluetooth.bluetoothAsPeripheral()
    weak var canvasPickerViewController : CanvasPickerViewController?
    var connectionProvider : ConnectionProvider?
    
    init() {
        let controller = ListViewController()
        super.init(rootViewController: controller)
        
        controller.delegate = self
        bluetooth.listDelegate = controller
        bluetooth.connectionDelegate = self
        
        bluetoothAsPeripheral.connectionDelegate = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NavigationController : ConnectionProviderDelegate {
    func establishedConnection(withModel: DataModel, connectionProvider: ConnectionProvider) {
        self.connectionProvider = connectionProvider
        DispatchQueue.main.async {
            if self.topViewController == self.canvasPickerViewController {
                self.canvasPickerViewController?.hideLoading()
            } else {
                //Connection initiator is other device
                let controller = CanvasPickerViewController()
                controller.delegate = self
                self.canvasPickerViewController = controller
                self.pushViewController(controller, animated: true)
            }
        }
    }
    
    func didDisconnect(fromModel: DataModel, withError error: Error?, connectionProvider: ConnectionProvider) {
        self.connectionProvider = nil
        DispatchQueue.main.async {
            self.popToRootViewController(animated: true)
            
            if let uError = error {
                let controller = UIAlertController.init(title: "Error", message: (uError as NSError).localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                controller.addAction(action)
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func failedConnection(with error: Error, inProvider provider: ConnectionProvider) {
        DispatchQueue.main.async {
            let controller = UIAlertController.init(title: "Error", message: (error as NSError).localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            controller.addAction(action)
            self.present(controller, animated: true, completion: nil)
        }
    }
}

extension NavigationController : ListViewControllerDelegate {
    func didSelect(peripheral: CBPeripheral, in controller: ListViewController) {
        let controller = CanvasPickerViewController()
        controller.delegate = self
        controller.showLoading()
        canvasPickerViewController = controller
        bluetooth.connect(peripheral: peripheral)
        pushViewController(controller, animated: true)
    }
    
    func peripherals(for controller: ListViewController) -> [CBPeripheral] {
        return bluetooth.peripherals()
    }
}

extension NavigationController : CanvasPickerViewControllerDelegate {
    func drawingCanvasSelected(in controller: CanvasPickerViewController) {
        let drawingCanvas = DrawingView()
        let remoteCanvas = RemoteCanvas(dataModel: connectionProvider!.model!)
        let controller = DrawingsViewController(view: drawingCanvas, remoteCanvas: remoteCanvas)
        pushViewController(controller, animated: true)
    }
    
    func glassCanvasSelected(in controller: CanvasPickerViewController) {
        let drawingCanvas = GlassView()
        let remoteCanvas = RemoteCanvas(dataModel: connectionProvider!.model!)
        let controller = DrawingsViewController(view: drawingCanvas, remoteCanvas: remoteCanvas)
        pushViewController(controller, animated: true)
    }
}

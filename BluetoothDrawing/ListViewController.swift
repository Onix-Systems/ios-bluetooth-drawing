//
//  ViewController.swift
//  BluetoothDrawing
//
//  Created by Oleksii Nezhyborets on 19.09.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit
import CoreBluetooth
import HEXColor

protocol ListViewControllerDelegate:class {
    func didSelect(peripheral: CBPeripheral, in controller: ListViewController)
    func peripherals(for controller: ListViewController) -> [CBPeripheral]
}

class ListViewController: UIViewController {
    let tableView = UITableView(frame: CGRect.zero, style: .plain)
    weak var delegate : ListViewControllerDelegate?
    fileprivate var peripherals : [CBPeripheral] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
        let v = tableView
        v.translatesAutoresizingMaskIntoConstraints = false
        let margins = self.view.layoutMarginsGuide
        NSLayoutConstraint.activate([v.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
                                     v.topAnchor.constraint(equalTo: margins.topAnchor, constant: 20),
                                     v.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
                                     v.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
            ])
    }
    
    fileprivate func reload() {
        peripherals = delegate?.peripherals(for: self) ?? []
        tableView.reloadData()
    }
}

extension ListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = peripherals[indexPath.row]
        delegate?.didSelect(peripheral: peripheral, in: self)
    }
}

extension ListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let peripheral = peripherals[indexPath.row]
        cell.textLabel?.text = peripheral.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = peripherals.count
        print("peripherals count \(count)")
        return count
    }
}

extension ListViewController : PeripheralsListDelegate {
    func didUpdate(peripherals: [CBPeripheral]) {
        print("PeripheralsListDelegate didUpdate peripherals")
        DispatchQueue.main.async {
            self.reload()
        }
    }
}


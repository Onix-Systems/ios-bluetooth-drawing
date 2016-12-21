//
//  ColorPickerViewController.swift
//  BluetoothDrawing
//
//  Created by Oleksii Nezhyborets on 20.09.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit

protocol ColorPickerViewControllerDelegate: class {
    func colorPickerViewController(conroller: ColorPickerViewController, pickedColor: UIColor)
}

class ColorPickerViewController: UIViewController, SwiftHUEColorPickerDelegate {
    weak var delegate : ColorPickerViewControllerDelegate?
    
    override func loadView() {
        super.loadView()
        
        let view = SwiftHUEColorPicker()
        view.type = .color
        view.direction = .vertical
        view.delegate = self
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(button)
        button.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        button.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.setTitle("Close", for: .normal)
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
    }
    
    func closeButtonAction() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func valuePicked(_ color: UIColor, type: SwiftHUEColorPicker.PickerType) {
        delegate?.colorPickerViewController(conroller: self, pickedColor: color)
    }
}

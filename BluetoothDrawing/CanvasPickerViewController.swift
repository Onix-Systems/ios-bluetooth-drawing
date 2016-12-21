//
//  CanvasPickerViewController.swift
//  BluetoothDrawing
//
//  Created by Oleksii Nezhyborets on 19.12.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit

protocol CanvasPickerViewControllerDelegate:class {
    func drawingCanvasSelected(in controller: CanvasPickerViewController)
    func glassCanvasSelected(in controller: CanvasPickerViewController)
}

class CanvasPickerViewController: UIViewController {
    weak var delegate: CanvasPickerViewControllerDelegate?
    
    override func loadView() {
        let view = UIView(frame: CGRect.zero)
        let drawingButton = UIButton(type: .system)
        drawingButton.setTitle("Draw", for: .normal)
        drawingButton.addTarget(self, action: #selector(drawingButtonAction), for: .touchUpInside)
        drawingButton.backgroundColor = .lightGray
        
        let glassButton = UIButton(type: .system)
        glassButton.setTitle("Finger (Glass)", for: .normal)
        glassButton.addTarget(self, action: #selector(glassButtonAction), for: .touchUpInside)
        glassButton.backgroundColor = .lightGray
        
        let stackView = UIStackView(arrangedSubviews: [drawingButton, glassButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.view = view
    }
    
    func drawingButtonAction() {
        delegate?.drawingCanvasSelected(in: self)
    }
    
    func glassButtonAction() {
        delegate?.glassCanvasSelected(in: self)
    }
    
    func showLoading() {
        for subview in view.subviews {
            subview.isUserInteractionEnabled = false
            subview.alpha = 0.5
        }
    }
    
    func hideLoading() {
        for subview in view.subviews {
            subview.isUserInteractionEnabled = true
            subview.alpha = 1
        }
    }
}

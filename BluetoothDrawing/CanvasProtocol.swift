//
//  CanvasProtocol.swift
//  BluetoothDrawing
//
//  Created by Oleksii Nezhyborets on 23.09.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit

@objc protocol CanvasProtocol {
    func begin(point: CGPoint)
    func move(point: CGPoint)
    func end(point: CGPoint)
    weak var delegate : CanvasDelegate? {get set}
    func identifier() -> String
}

@objc protocol CanvasDelegate: class {
    func canvas(canvas: CanvasProtocol, didEndWith point: CGPoint)
    func canvas(canvas: CanvasProtocol, didBeginWith point: CGPoint)
    func canvas(canvas: CanvasProtocol, didMoveTo point: CGPoint)
}

func ==(lhs: CanvasProtocol, rhs: CanvasProtocol) -> Bool {
    return lhs.identifier() == rhs.identifier()
}

func !=(lhs: CanvasProtocol, rhs: CanvasProtocol) -> Bool {
    return lhs.identifier() != rhs.identifier()
}

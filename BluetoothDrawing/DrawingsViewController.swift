//
//  DrawingsViewController.swift
//  BluetoothDrawing
//
//  Created by Alexei on 12/16/16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit

class DrawingsViewController: UIViewController {
    let canvases : [CanvasProtocol]
    
    init<T : UIView>(view: T, remoteCanvas: CanvasProtocol) where T: CanvasProtocol {
        canvases = [view, remoteCanvas]
        super.init(nibName: nil, bundle: nil)
        self.view = view
        view.delegate = self
        remoteCanvas.delegate = self
    }
     
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DrawingsViewController : CanvasDelegate {
    func canvas(canvas: CanvasProtocol, didBeginWith point: CGPoint) {
        for someCanvas in canvases {
            if someCanvas != canvas {
                someCanvas.begin(point: point)
            }
        }
    }
    
    func canvas(canvas: CanvasProtocol, didMoveTo point: CGPoint) {
        for someCanvas in canvases {
            if someCanvas != canvas {
                someCanvas.move(point: point)
            }
        }
    }
    
    func canvas(canvas: CanvasProtocol, didEndWith point: CGPoint) {
        for someCanvas in canvases {
            if someCanvas != canvas {
                someCanvas.end(point: point)
            }
        }
    }
}

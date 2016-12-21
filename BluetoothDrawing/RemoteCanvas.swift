//
//  CanvasDataModel.swift
//  BluetoothDrawing
//
//  Created by Oleksii Nezhyborets on 19.12.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit

class RemoteCanvas : CanvasProtocol {
    let dataModel : DataModel
    init(dataModel: DataModel) {
        self.dataModel = dataModel
        self.dataModel.dataDelegate = self
    }
    
    weak var delegate: CanvasDelegate?
    
    func identifier() -> String {
        return "remoteCanvas"
    }
    
    func begin(point: CGPoint) {
        distance = 0
        lastSentPoint = point
        lastPoint = point
        let dictToSend = dict(withStep: "begin", point: point)
        dataModel.write(dataJson: dictToSend)
    }
    
    func move(point: CGPoint) {
        if filter {
            filter = false
            return
        }
        
        filter = true
        lastPoint = point
        let distanceToLastPoint = pointsDistance(point1: lastPoint!, point2: point)
        if distanceToLastPoint >= 2 {
            sendMove(point: point)
            return
        }
        
        let distanceToLastSentPoint = pointsDistance(point1: lastSentPoint!, point2: point)
        if distanceToLastSentPoint >= 2 {
            sendMove(point: point)
        }
    }
    
    func end(point: CGPoint) {
        let dictToSend = dict(withStep: "end", point: point)
        dataModel.write(dataJson: dictToSend)
        lastSentPoint = nil
        lastPoint = nil
        distance = 0
    }
    
    fileprivate var mutableData : NSMutableData?
    fileprivate var distance = 0.0
    fileprivate var lastSentPoint : CGPoint?
    fileprivate var lastPoint : CGPoint?
    fileprivate var filter = false
    
    private func dict(withStep step: String, point: CGPoint?) -> [String : AnyObject] {
        var dict : [String : AnyObject] = ["step" : step as AnyObject]
        if let uPoint = point {
            dict["point"] = NSStringFromCGPoint(uPoint) as NSObject?
        }
        
        return dict
    }
    
    private func pointsDistance(point1: CGPoint, point2: CGPoint) -> CGFloat {
        let xDist = abs(point2.x - point1.x)
        let yDist = abs(point2.y - point1.y)
        
        let distance = max(xDist, yDist)
        return distance
    }
    
    private func sendMove(point: CGPoint) {
        lastSentPoint = point
        self.distance = 0
        let dictToSend = dict(withStep: "move", point: point)
        dataModel.write(dataJson: dictToSend)
    }
}

extension RemoteCanvas : DataModelDelegate {
    func didGet(newData json: [String : AnyObject], inModel model: DataModel) {
        let stepString = json["step"] as! String
        let pointString = json["point"] as? String
        
        if stepString == "begin" {
            let point = CGPointFromString(pointString!)
            delegate?.canvas(canvas: self, didBeginWith: point)
//            drawView.begin(point: point)
        } else if stepString == "move" {
            let point = CGPointFromString(pointString!)
            delegate?.canvas(canvas: self, didMoveTo: point)
//            drawView.move(point: point)
        } else if stepString == "end" {
            let point = CGPointFromString(pointString!)
            delegate?.canvas(canvas: self, didEndWith: point)
//            drawView.end(point: point)
        } else {
            fatalError()
        }
    }
}

//
//  DrawingView.swift
//  BluetoothDrawing
//
//  Created by Oleksii Nezhyborets on 20.12.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit

class DrawingView: UIView {
    weak var delegate : CanvasDelegate?
    
    private let localDrawing = DrawingInfo(color: .black, points: [:], counter: 0)
    fileprivate let remoteDrawing = DrawingInfo(color: .red, points: [:], counter: 0)
    
    var incrementalImage : UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isMultipleTouchEnabled = false
        backgroundColor = .white
        
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        
        button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        button.heightAnchor .constraint(equalToConstant: 44)
        button.setTitle("Color", for: .normal)
        button.addTarget(self, action: #selector(colorButtonAction(sender:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func colorButtonAction(sender: AnyObject) {
        //[self.delegate drawingView:self colorAction:sender];
    }
    
    override func draw(_ rect: CGRect) {
        incrementalImage?.draw(in: rect)
        localDrawing.color.setStroke()
        localDrawing.path.stroke()
        remoteDrawing.color.setStroke()
        remoteDrawing.path.stroke()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let point = touch.location(in: self)
        begin(drawing: localDrawing, withPoint: point)
        delegate?.canvas(canvas: self, didBeginWith: point)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let point = touch.location(in: self)
        
        move(drawing: localDrawing, toPoint: point)
        delegate?.canvas(canvas: self, didMoveTo: point)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        end(drawing: localDrawing)
        
        let touch = touches.first!
        let point = touch.location(in: self)
        delegate?.canvas(canvas: self, didEndWith: point)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }
    
    fileprivate func begin(drawing: DrawingInfo, withPoint point: CGPoint) {
        drawing.points = [:]
        drawing.points[0] = point
        drawing.counter = 0
    }
    
    fileprivate func move(drawing: DrawingInfo, toPoint point: CGPoint) {
        drawing.counter += 1;
        drawing.points[drawing.counter] = point;
        if (drawing.counter == 4)
        {
            drawing.points[3] = CGPoint(x: (drawing.points[2]!.x + drawing.points[4]!.x)/2.0, y: (drawing.points[2]!.y + drawing.points[4]!.y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
            
            drawing.path.move(to: drawing.points[0]!)
            drawing.path.addCurve(to: drawing.points[3]!, controlPoint1: drawing.points[1]!, controlPoint2: drawing.points[2]!)
            
            self.setNeedsDisplay()
            // replace points and get ready to handle the next segment
            drawing.points[0] = drawing.points[3];
            drawing.points[1] = drawing.points[4];
            drawing.counter = 1;
        }
    }
    
    fileprivate func end(drawing: DrawingInfo) {
        drawBitmap()
        setNeedsDisplay()
        drawing.path.removeAllPoints()
        drawing.counter = 0
        drawing.points = [:]
    }
    
    private func drawBitmap() {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0.0);
        
        if incrementalImage == nil // first time; paint background white
        {
            let rectPath = UIBezierPath(rect: bounds)
            UIColor.white.setFill()
            rectPath.fill()
        }
        
        incrementalImage?.draw(at: CGPoint.zero)
        localDrawing.color.setStroke()
        localDrawing.path.stroke()
        
        remoteDrawing.color.setStroke()
        remoteDrawing.path.stroke()
        
        incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

extension DrawingView : CanvasProtocol {
    func begin(point: CGPoint) {
        begin(drawing: remoteDrawing, withPoint: point)
    }
    
    func move(point: CGPoint) {
        move(drawing: remoteDrawing, toPoint: point)
    }
    
    func end(point: CGPoint) {
        end(drawing: remoteDrawing)
    }
    
    func identifier() -> String {
        return "DrawingViewCanvas"
    }
}

fileprivate class DrawingInfo {
    var color : UIColor
    var points : [Int : CGPoint]
    var counter : Int
    
    var path : UIBezierPath = {
        let p = UIBezierPath()
        p.lineWidth = 2.0
        return p
    }()
    
    init(color: UIColor, points: [Int : CGPoint], counter: Int) {
        self.color = color
        self.points = points
        self.counter = counter
    }
}

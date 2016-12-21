//
//  GlassView.swift
//  BluetoothDrawing
//
//  Created by Oleksii Nezhyborets on 23.09.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit

class GlassView: UIView {
    let glassImageView = UIImageView(image: UIImage(named: "background"))
    let fingerImageView = UIImageView(image: UIImage(named: "hand"))
    
    weak var delegate: CanvasDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        
        
        super.init(frame: frame)
        
        setup()
    }
    
    private func setup() {
        glassImageView.translatesAutoresizingMaskIntoConstraints = false
        glassImageView.contentMode = .scaleAspectFill
        self.addSubview(glassImageView)
        let margins = self
        let v = glassImageView
        NSLayoutConstraint.activate([v.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
                                     v.topAnchor.constraint(equalTo: margins.topAnchor),
                                     v.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
                                     v.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
            ])
        
        fingerImageView.alpha = 0
        fingerImageView.translatesAutoresizingMaskIntoConstraints = false
        fingerImageView.layoutIfNeeded()
        handSize = fingerImageView.frame.size
        self.addSubview(fingerImageView)
    }
    
    var handSize : CGSize!
    
    fileprivate func moveHand(point: CGPoint, duration: TimeInterval, options: UIViewAnimationOptions) {
        //finger to origin ratio
        let xRatio = 0.338
        let yRatio = 0.08
        
        let xOffset = handSize.width * CGFloat(xRatio)
        let yOffset = handSize.height * CGFloat(yRatio)
        
        let frame = CGRect(x: point.x - xOffset, y: point.y - yOffset, width: handSize.width, height: handSize.height)
        
        let options = UIViewAnimationOptions.beginFromCurrentState.union(options)
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.fingerImageView.frame = frame
            self.fingerImageView.sizeToFit()
            }, completion: nil)
    }
    
    fileprivate func moveHand(point: CGPoint, options: UIViewAnimationOptions) {
        moveHand(point: point, duration: 0.1, options: options)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let point = touch.location(in: self)
        self.delegate?.canvas(canvas: self, didBeginWith: point)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let point = touch.location(in: self)
        self.delegate?.canvas(canvas: self, didMoveTo: point)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let point = touch.location(in: self)
        self.delegate?.canvas(canvas: self, didEndWith: point)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }
    
    fileprivate func setStartingPositionForHandViewsFromPoint(point: CGPoint) {
        let width = handSize.width * 0.5
        let height = handSize.width * 0.5
        let frame = CGRect(x: point.x, y: point.y, width: width, height: height)
        fingerImageView.frame = frame
    }
}

extension GlassView : CanvasProtocol {
    func begin(point: CGPoint) {
        self.fingerImageView.alpha = 0
        setStartingPositionForHandViewsFromPoint(point: point)
        self.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.1) {
            self.fingerImageView.alpha = 1
        }
        
        moveHand(point: point, options: .curveEaseOut)
    }
    
    func move(point: CGPoint) {
        moveHand(point: point, options: .curveLinear)
    }
    
    func end(point: CGPoint) {
        UIView.animate(withDuration: 0.1) {
            self.fingerImageView.alpha = 0
            self.setStartingPositionForHandViewsFromPoint(point: point)
        }
    }
    
    func identifier() -> String {
        return "glassViewCanvas"
    }
}

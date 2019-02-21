//
//  ColorSliderView.swift
//  ColorPickerView
//
//  Created by anthann on 2019/2/21.
//  Copyright © 2019 anthann. All rights reserved.
//

import UIKit

internal class ColorSliderView: UIControl {
    public var brightness: CGFloat = 0.5
    private var hue: CGFloat = 0.0
    private var saturation: CGFloat = 0.0
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    private let knobLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.cornerRadius = 6.0
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.colors = [
            UIColor(hue: hue, saturation: saturation, brightness: 0.0, alpha: 1.0).cgColor,
            UIColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0).cgColor
        ]
        self.layer.addSublayer(gradientLayer)
        
        knobLayer.cornerRadius = 3.0
        knobLayer.borderColor = UIColor.black.cgColor
        knobLayer.borderWidth = 0.5
        knobLayer.backgroundColor = UIColor.white.cgColor
        knobLayer.bounds = CGRect(x: 0, y: 0, width: 6.0, height: 22.0)
        self.layer.addSublayer(knobLayer)
//
//        let gr = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized))
//        self.addGestureRecognizer(gr)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func set(hue: CGFloat, saturation: CGFloat) {
        self.hue = hue
        self.saturation = saturation
        gradientLayer.colors = [
            UIColor(hue: hue, saturation: saturation, brightness: 0.0, alpha: 1.0).cgColor,
            UIColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0).cgColor
        ]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height: CGFloat = 12.0
        gradientLayer.frame = CGRect(x: 0.0, y: self.bounds.height / 2.0 - height / 2.0, width: self.bounds.width, height: height)
        knobLayer.position = CGPoint(x: brightness * self.bounds.width, y: self.bounds.height / 2.0)
    }
    
    @objc private func panGestureRecognized(sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        case .began:
            fallthrough
        case .changed:
            fallthrough
        case .ended:
            let position = sender.location(in: self)
            touchAtPosition(position)
        default:
            break
        }
    }
}

//MARK: UIControl
extension ColorSliderView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let position = touches.first?.location(in: self) else {
            return
        }
        touchAtPosition(position)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let position = touches.first?.location(in: self) else {
            return
        }
        touchAtPosition(position)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let position = touches.first?.location(in: self) else {
            return
        }
        touchAtPosition(position)
    }
    
    private func touchAtPosition(_ position: CGPoint) {
        let width = self.bounds.width
        var brightness = position.x / width
        brightness = min(brightness, 1.0)
        brightness = max(brightness, 0.0)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        knobLayer.position = CGPoint(x: brightness * self.bounds.width, y: self.bounds.height / 2.0)
        CATransaction.commit()
        self.brightness = brightness
        self.sendActions(for: .valueChanged)
    }
}

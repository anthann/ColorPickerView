//
//  ColorWheelView.swift
//  ColorPickerView
//
//  Created by anthann on 2019/2/21.
//  Copyright © 2019 anthann. All rights reserved.
//

import UIKit

internal class ColorWheelView: UIControl {
    public var hue: CGFloat = 0.0
    public var saturation: CGFloat = 0.0
    private lazy var knobLayer: CALayer = {
        let dimension: CGFloat = 32.0
        let layer = CALayer()
        layer.isOpaque = true
        layer.cornerRadius = dimension / 2.0
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2.0
        layer.bounds = CGRect(x: 0, y: 0, width: dimension, height: dimension)
        layer.backgroundColor = UIColor.white.cgColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isOpaque = true
        self.layer.addSublayer(knobLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if knobLayer.position == CGPoint.zero {
            let width = self.bounds.width
            let radius = width / 2.0
            knobLayer.position = CGPoint(x: radius, y: radius)
        }
    }
}

//MARK: UIControl
extension ColorWheelView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let position = touches.first?.location(in: self) else {
            return
        }
        self.knobLayer.transform = CATransform3DMakeScale(1.5, 1.5, 0)
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
        self.knobLayer.transform = CATransform3DIdentity
        touchAtPosition(position)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.knobLayer.transform = CATransform3DIdentity
    }
    
    private func touchAtPosition(_ position: CGPoint) {
        let width = self.bounds.width
        let radius = width / 2.0
        let offsetX = position.x - radius
        let offsetY = position.y - radius
        let distance = sqrt(offsetX * offsetX + offsetY * offsetY)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if distance > radius {
            // 把Position修正到圆上
            let y = offsetY * radius / distance + radius
            let x = offsetX * radius / distance + radius
            let amendPosition = CGPoint(x: x, y: y)
            (self.hue, _) = colorAtPosition(amendPosition, width: Int(width))
            self.saturation = 1.0
            self.knobLayer.position = amendPosition
        } else {
            if distance < 16 {
                self.hue = 0.0
                self.saturation = 0.0
                self.knobLayer.position = CGPoint(x: radius, y: radius)
            } else {
                (self.hue, self.saturation) = colorAtPosition(position, width: Int(width))
                self.knobLayer.position = position
            }
        }
        self.knobLayer.backgroundColor = UIColor(hue: self.hue, saturation: self.saturation, brightness: 1.0, alpha: 1.0).cgColor
        CATransaction.commit()
        self.sendActions(for: .valueChanged)
    }
}

//MARK: - Drawing
extension ColorWheelView {
    override func draw(_ rect: CGRect) {
        UIColor.white.setFill()
        UIRectFill(rect)
        
        let width = Int(rect.width * UIScreen.main.scale)
        let data = colorWheelBitmap(width: width) as NSData
        guard let providerRef = CGDataProvider(data: data) else {
            return
        }
        guard let cgImage = CGImage(
            width: width,
            height: width,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
            )
            else {
                return
        }
        let image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: UIImage.Orientation.up)
        image.draw(at: CGPoint.zero)
    }
    
    private func colorWheelBitmap(width: Int) -> NSData {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: width * width * 4)
        buffer.initialize(to: 0xff)
        for y in 0..<width {
            for x in 0..<width {
                let (hue, saturation) = colorAtPosition(CGPoint(x: x, y: y), width: width)
                var r: CGFloat = 0.0
                var g: CGFloat = 0.0
                var b: CGFloat = 0.0
                var a: CGFloat = 0.0
                if saturation < 1.0 {
                    if (saturation > 0.99) {
                        a = (1.0 - saturation) * 100.0;
                    } else {
                        a = 1.0;
                    }
                    (r, g, b) = hsb2rgb(hue: hue, saturation: saturation, brightness: 1.0)
                }
                
                let i = 4 * (x + y * width)
                buffer[i] = UInt8(r * 255.0)
                buffer[i+1] = UInt8(g * 255.0)
                buffer[i+2] = UInt8(b * 255.0)
                buffer[i+3] = UInt8(a * 255.0)
            }
        }
        return NSData(bytes: buffer, length: width * width * 4)
    }
    
    private func colorAtPosition(_ position: CGPoint, width: Int) -> (CGFloat, CGFloat) {
        let w = CGFloat(width)
        let radius = w / 2.0
        let dx = (position.x - radius) / radius
        let dy = (position.y - radius) / radius
        let dr = sqrt(dx * dx + dy * dy)
        let saturation = dr
        var hue = 0.0
        if abs(dr - 0.0) > 1e-6 {
            hue = acos(Double(dx) / Double(dr)) / Double.pi / 2.0
            if dy < 0.0 {
                hue = 1.0 - hue
            }
        }
        return (CGFloat(hue), saturation)
    }
    
    private func hsb2rgb(hue: CGFloat, saturation: CGFloat, brightness: CGFloat) -> (CGFloat, CGFloat, CGFloat) {
        let i = Int(hue * 6.0)
        let f = hue * 6.0 - CGFloat(i)
        let p = brightness * (1.0 - saturation)
        let q = brightness * (1.0 - f * saturation)
        let t = brightness * (1.0 - (1.0 - f) * saturation)
        if i == 0 {
            return (brightness, t, p)
        } else if i == 1 {
            return (q, brightness, p)
        } else if i == 2 {
            return (p, brightness, t)
        } else if i == 3 {
            return (p, q, brightness)
        } else if i == 4 {
            return (t, p, brightness)
        } else if i == 5 {
            return (brightness, p ,q)
        } else {
            print("error")
            return (0, 0, 0)
        }
    }
    
    
}

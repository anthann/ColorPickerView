//
//  ColorPickerView.swift
//  ColorPickerView
//
//  Created by anthann on 2019/2/21.
//  Copyright © 2019 anthann. All rights reserved.
//

import UIKit
import SnapKit

internal class ColorPickerView: UIControl {
    static let preferedWidth: CGFloat = 300.0
    static let preferedHeight: CGFloat = 12.0 + 50.0 + 8.0 + (ColorPickerView.preferedWidth - 12.0 * 2.0) + 8.0 + 44.0
    
    public var color: UIColor {
        get {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
        }
        set {
            var _hue: CGFloat = 0.0
            var _saturation: CGFloat = 0.0
            var _brightness: CGFloat = 0.0
            if newValue.getHue(&_hue, saturation: &_saturation, brightness: &_brightness, alpha: nil) {
                hue = _hue
                saturation = _saturation
                brightness = _brightness
                wheelView.set(hue: _hue, saturation: _saturation)
                sliderView.brightness = _brightness
                sliderView.set(hue: _hue, saturation: _saturation)
                currentColorView.backgroundColor = newValue
            }
        }
    }
    
    private var brightness: CGFloat = 0.5
    private var hue: CGFloat = 0.0
    private var saturation: CGFloat = 0.0
    
    private lazy var wheelView = ColorWheelView()
    private lazy var sliderView = ColorSliderView()
    private lazy var currentColorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        currentColorView.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
        addSubview(currentColorView)
        currentColorView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(50)
        }
        
        wheelView.addTarget(self, action: #selector(wheelViewValueChanged), for: .valueChanged)
        addSubview(wheelView)
        wheelView.snp.makeConstraints { (make) in
            make.left.right.equalTo(currentColorView)
            make.top.equalTo(currentColorView.snp.bottom).offset(8)
            make.height.equalTo(wheelView.snp.width)
        }
        
        sliderView.addTarget(self, action: #selector(sliderViewValueChanged), for: .valueChanged)
        addSubview(sliderView)
        sliderView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(wheelView.snp.bottom).offset(8)
            make.height.equalTo(44)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: ColorPickerView.preferedWidth, height: ColorPickerView.preferedHeight)
    }
    
    @objc private func wheelViewValueChanged(sender: ColorWheelView) {
        hue = sender.hue
        saturation = sender.saturation
        currentColorView.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
        sliderView.set(hue: sender.hue, saturation: sender.saturation)
        self.sendActions(for: .valueChanged)
    }
    
    @objc private func sliderViewValueChanged(sender: ColorSliderView) {
        brightness = sender.brightness
        currentColorView.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
        self.sendActions(for: .valueChanged)
    }
}

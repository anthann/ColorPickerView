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
    public var brightness: CGFloat = 0.5
    public var hue: CGFloat = 0.0
    public var saturation: CGFloat = 0.0
    
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
        let width: CGFloat = 300.0
        let height = 12.0 + 50.0 + 8.0 + (width - 12.0 * 2.0) + 8.0 + 44.0
        return CGSize(width: width, height: height)
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

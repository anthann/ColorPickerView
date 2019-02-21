//
//  ViewController.swift
//  ColorPickerView
//
//  Created by anthann on 2019/2/21.
//  Copyright © 2019 anthann. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let pickerView = ColorPickerView()
        self.view.addSubview(pickerView)
        pickerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}


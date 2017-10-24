//
//  UICustom.swift
//  PEMO
//
//  Created by Jaeseong on 2017. 10. 23..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//

import UIKit


extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

extension UIView {
    // 메인화면 하단 View Top Border
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: width)
        self.layer.addSublayer(border)
    }
}

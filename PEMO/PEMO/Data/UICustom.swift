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
        
        border.shadowColor = UIColor.piGreyish.cgColor
        border.shadowOffset = CGSize(width: 0.0, height: 0.0)
        border.shadowOpacity = 0.4
        border.masksToBounds = false
        
        border.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: width)
        self.layer.addSublayer(border)
    }
}
extension UIColor {
    @nonobjc class var piWhite: UIColor {
        return UIColor(white: 237.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var piViolet: UIColor {
        return UIColor(red: 189.0 / 255.0, green: 16.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var piPaleGrey: UIColor {
        return UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var piAquamarine: UIColor {
        return UIColor(red: 0.0, green: 215.0 / 255.0, blue: 203.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var piGreyish: UIColor {
        return UIColor(white: 178.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var piBrownishGrey: UIColor {
        return UIColor(white: 102.0 / 255.0, alpha: 1.0)
    }
}
extension UIView {
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String:UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary ))
    }
}

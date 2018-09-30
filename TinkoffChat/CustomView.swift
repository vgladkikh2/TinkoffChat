//
//  CustomView.swift
//  TinkoffChat
//
//  Created by me on 01/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

import UIKit

@IBDesignable
class CustomView: UIView {
    //    let sizeCoefficient = self.view.frame.size.width / 375.0
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.layer.cornerRadius = cornerRadius
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = cornerRadius
    }
}

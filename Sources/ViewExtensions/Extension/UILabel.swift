//
//  UILabel.swift
//  
//
//  Created by Ilya Senchukov on 04.12.2021.
//

import UIKit

extension UILabel: FontRoundable {

    public func setRoundedFont() {
        if let descriptor = font.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: font.pointSize)
        }
    }

}

//
//  UIFont.swift
//  
//
//  Created by Ilya Senchukov on 17.12.2021.
//

import UIKit

public extension UIFont {

    static func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = font.fontDescriptor.withDesign(.rounded) else {
            return font
        }
        return .init(descriptor: descriptor, size: size)
    }

}

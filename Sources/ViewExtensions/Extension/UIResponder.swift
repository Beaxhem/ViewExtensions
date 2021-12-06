//
//  UIResponder.swift
//  Dyet
//
//  Created by Ilya Senchukov on 11.07.2021.
//

import UIKit

extension UIResponder {

    @objc open class var reuseIdentifier: String {
        String(describing: Self.self)
    }

}

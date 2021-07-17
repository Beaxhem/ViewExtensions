//
//  UIResponder.swift
//  Dyet
//
//  Created by Ilya Senchukov on 11.07.2021.
//

import UIKit

public extension UIResponder {

    class var reuseIdentifier: String {
        String(describing: Self.self)
    }

}

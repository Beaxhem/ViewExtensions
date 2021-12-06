//
//  UIColor.swift
//  
//
//  Created by Ilya Senchukov on 26.11.2021.
//

import UIKit

public extension UIColor {

    convenience init(hex: String) {
        let hexint = Self.intFrom(hexString: hex)
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

    private static func intFrom(hexString: String) -> Int {
        let scanner: Scanner = Scanner(string: hexString)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        return Int(UInt32(bitPattern: scanner.scanInt32(representation: .hexadecimal) ?? 0))
    }
    
}

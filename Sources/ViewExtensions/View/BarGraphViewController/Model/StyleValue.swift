//
//  StyleValue.swift
//  
//
//  Created by Ilya Senchukov on 18.10.2021.
//

import UIKit

public enum StyleValue {
    case value(CGFloat)
    case `default`

    var value: CGFloat? {
        switch self {
            case .default:
                return nil
            case .value(let value):
                return value
        }
    }
}

//
//  StyleValue.swift
//  
//
//  Created by Ilya Senchukov on 18.10.2021.
//

import UIKit

public enum StyleValue<T> {
    case value(T)
    case `default`

    var value: T? {
        switch self {
            case .default:
                return nil
            case .value(let value):
                return value
        }
    }
}

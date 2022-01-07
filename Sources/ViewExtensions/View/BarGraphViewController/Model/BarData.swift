//
//  BarData.swift
//  
//
//  Created by Ilya Senchukov on 17.10.2021.
//

import UIKit

public struct BarData {
    var value: String
    var label: String
    public var percentage: CGFloat

    public init(value: String, label: String, percentage: CGFloat) {
        self.value = value
        self.label = label
        self.percentage = percentage
    }
}

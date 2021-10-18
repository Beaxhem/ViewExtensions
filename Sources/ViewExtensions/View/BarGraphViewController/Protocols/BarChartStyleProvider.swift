//
//  StyleProvider.swift
//  
//
//  Created by Ilya Senchukov on 17.10.2021.
//

import UIKit

public protocol BarChartStyleProvider: AnyObject {

    func styleTitleLabel(_ label: UILabel)
    func styleControlButton(_ button: UIButton)
    func styleBar(_ bar: UIView)
    func styleValueLabel(_ label: UILabel)
    func styleBarTitleLabel(_ label: UILabel)

}

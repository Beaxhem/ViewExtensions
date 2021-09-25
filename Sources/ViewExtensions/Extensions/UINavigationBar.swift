//
//  UINavigationBar.swift
//  
//
//  Created by Ilya Senchukov on 26.09.2021.
//

import UIKit

extension UINavigationBar {

    public func toggle() {
        layer.zPosition = layer.zPosition == -1 ? 0 : -1
        isUserInteractionEnabled.toggle()
    }

}

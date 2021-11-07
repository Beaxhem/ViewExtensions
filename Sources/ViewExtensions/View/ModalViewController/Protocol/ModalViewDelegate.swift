//
//  ModalViewDelegate.swift
//  
//
//  Created by Ilya Senchukov on 07.11.2021.
//

import UIKit

@objc
public protocol ModalViewDelegate: AnyObject {

    @objc optional func didScroll(offsetY: CGFloat)

    @objc optional func didEndScroll(offsetY: CGFloat)

}

//
//  ModalPresented.swift
//  
//
//  Created by Ilya Senchukov on 04.10.2021.
//

import UIKit

public protocol ModalPresented: UIViewController {

    var modalViewController: ModalViewController? { get set }

    var contentHeight: CGFloat { get }

}

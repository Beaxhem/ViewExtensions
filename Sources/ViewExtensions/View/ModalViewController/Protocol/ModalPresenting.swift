//
//  ModalPresenting.swift
//  
//
//  Created by Ilya Senchukov on 10.01.2022.
//

import UIKit

public protocol ModalPresenting: UIViewController {
    var modalViewController: ModalViewController? { get set }
}

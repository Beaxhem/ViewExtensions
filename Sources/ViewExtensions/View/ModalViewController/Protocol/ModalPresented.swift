//
//  ModalPresented.swift
//  
//
//  Created by Ilya Senchukov on 04.10.2021.
//

import UIKit

public protocol ModalPresented: UIViewController {

    var modalViewController: ModalViewController? { get set }

    var _contentHeight: CGFloat { get }

    var contentView: UIView? { get }

    var dimmingView: UIView? { get }

}

extension ModalPresented {

    var clampedContentHeight: CGFloat {
        min(_contentHeight, modalViewController?.maxHeight ?? 0)
    }
}

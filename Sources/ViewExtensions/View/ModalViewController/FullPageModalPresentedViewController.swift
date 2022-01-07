//
//  FullPageModalPresentedViewController.swift
//  
//
//  Created by Ilya Senchukov on 08.12.2021.
//

import UIKit

public protocol FullPageModalPresentedViewController: ModalPresented { }

public extension FullPageModalPresentedViewController {

    var _contentHeight: CGFloat {
        modalViewController?.maxHeight ?? 0
    }

}

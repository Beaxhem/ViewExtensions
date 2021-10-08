//
//  PopoverDisplayingViewController.swift
//  
//
//  Created by Ilya Senchukov on 08.10.2021.
//

import UIKit

public protocol PopoverDisplayingViewController: UIViewController {

    var popover: PopoverView? { get set }

}

extension PopoverDisplayingViewController {

    func deinitPopover() {
        popover = nil
    }

}

//
//  UIViewController.swift
//  Dyet
//
//  Created by Ilya Senchukov on 11.07.2021.
//

import UIKit

public extension UIViewController {

    func move<T: UIViewController>(to parent: T, viewPath: KeyPath<T, UIView> = \.view) {
        parent.addChild(self)
        parent[keyPath: viewPath].addSubview(self.view)
        didMove(toParent: parent)
    }

    static func instantiate() -> Self {
        return Self.init(nibName: Self.reuseIdentifier, bundle: nil)
    }

}

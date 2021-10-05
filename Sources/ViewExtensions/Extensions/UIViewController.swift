//
//  UIViewController.swift
//  Dyet
//
//  Created by Ilya Senchukov on 11.07.2021.
//

import UIKit

public extension UIViewController {

    static func instantiate() -> Self {
        return Self.init(nibName: Self.reuseIdentifier, bundle: nil)
    }

    var topSafeArea: CGFloat {
        UIApplication.shared.windows.first!.safeAreaInsets.top
    }

    var bottomSafeArea: CGFloat {
        UIApplication.shared.windows.first!.safeAreaInsets.bottom
    }

    func move<T: UIViewController>(to parent: T, viewPath: KeyPath<T, UIView> = \.view) {
        parent.addChild(self)
        parent[keyPath: viewPath].addSubview(self.view)
        didMove(toParent: parent)
    }

    func moveAndFit<T: UIViewController>(to parent: T, viewPath: KeyPath<T, UIView> = \.view) {
        move(to: parent, viewPath: viewPath)
        parent[keyPath: viewPath].fit(view)
    }

    func remove() {
        view.removeFromSuperview()
        removeFromParent()
    }

}

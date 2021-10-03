//
//  UIView.swift
//  Dyet
//
//  Created by Ilya Senchukov on 09.07.2021.
//

import UIKit

public extension UIView {

    // MARK: -Layout
    func fit(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func forceLayout() {
        setNeedsLayout()
        layoutIfNeeded()
    }

    // MARK: -Layers

   func roundCorners(corners: CACornerMask, radius: CGFloat) {
       layer.cornerRadius = radius
       layer.maskedCorners = corners
    }


}

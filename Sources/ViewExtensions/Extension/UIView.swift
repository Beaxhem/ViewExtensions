//
//  UIView.swift
//  Dyet
//
//  Created by Ilya Senchukov on 09.07.2021.
//

import UIKit

public extension UIView {

    static func springAnimation(duration: TimeInterval,
                                delay: CGFloat = 0,
                                damping: CGFloat = 0.8,
                                initialSpringVelocity: CGFloat = 0.5,
                                options: AnimationOptions = [.curveEaseOut],
                                animations: @escaping () -> Void,
                                completion: (() -> Void)? = nil
    ) {
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: initialSpringVelocity,
                       options: options) {
            animations()
        } completion: { _ in
            completion?()
        }
    }

    // MARK: - Layout

    func fit(_ view: UIView, margins: UIEdgeInsets = .zero) {
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            leadingAnchor --> view.leadingAnchor + margins.left,
            topAnchor --> view.topAnchor + margins.top,
            trailingAnchor --> view.trailingAnchor + margins.right,
            bottomAnchor --> view.bottomAnchor + margins.bottom
        ])
    }

    func fit(_ view: UIView, constant: CGFloat) {
        let margins = UIEdgeInsets(top: -constant,
                                   left: -constant,
                                   bottom: constant,
                                   right: constant)
        fit(view, margins: margins)
    }

    func forceLayout() {
        setNeedsLayout()
        layoutIfNeeded()
    }

    // MARK: - Layers

   func roundCorners(corners: CACornerMask, radius: CGFloat) {
       layer.cornerRadius = radius
       layer.maskedCorners = corners
    }

}

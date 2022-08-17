//
//  UIView.swift
//  Dyet
//
//  Created by Ilya Senchukov on 09.07.2021.
//

import UIKit

public extension UIView {

    class func fromNib<T: UIView>() -> T {
        // swiftlint:disable:next force_cast
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }

}

public extension UIView {

	// MARK: - Corners

	var cornerRadius: CGFloat {
		get {
			layer.cornerRadius
		}

		set {
			layer.cornerRadius = newValue
		}
	}

	func roundCorners(corners: CACornerMask, radius: CGFloat) {
		cornerRadius = radius
		layer.maskedCorners = corners
		layer.masksToBounds = radius > 0
	}

	func roundCorners(corners: UIRectCorner, radius: CGFloat) {
		roundCorners(corners: CACornerMask(rawValue: corners.rawValue), radius: radius)
	}

	func roundToCircle() {
		roundCorners(corners: .allCorners, radius: bounds.height / 2)
	}

	func roundCorners(radius: CGFloat) {
		roundCorners(corners: .allCorners, radius: radius)
	}

	@discardableResult
	func applyRoundedPath(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
		let path = UIBezierPath(roundedRect: bounds,
								byRoundingCorners: corners,
								cornerRadii: .init(width: radius,
												   height: radius))
		let maskLayer = CAShapeLayer()
		maskLayer.path = path.cgPath
		layer.mask = maskLayer
		return maskLayer
	}

	@discardableResult
	func applyRoundedPath(radius: CGFloat) -> CAShapeLayer {
		applyRoundedPath(corners: .allCorners, radius: radius)
	}

	@discardableResult
	func applyRoundedPath() -> CAShapeLayer {
		applyRoundedPath(radius: frame.height / 2)
	}

	// MARK: - Animation

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

}

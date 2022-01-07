//
//  ContainerCell.swift
//  ContainerCell
//
//  Created by Ilya Senchukov on 21.07.2021.
//

import UIKit

public class ContainerCell: UICollectionViewCell {

    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?

    public var size: CGSize? {
        didSet {
            guard let size = size else { return }

            if var widthConstraint = widthConstraint {
                widthConstraint == size.width
            } else {
                widthConstraint = contentView.widthAnchor == size.width
            }

            if var heightConstraint = heightConstraint {
                heightConstraint == size.height
            } else {
                heightConstraint = contentView.heightAnchor == size.height
            }

            NSLayoutConstraint.activate([widthConstraint, heightConstraint].compactMap {
                $0?.priority = .defaultHigh
                return $0
            })
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        contentView.subviews.first?.frame = bounds
    }

    public override func prepareForReuse() {
        super.prepareForReuse()

        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
    }

    public func add(_ view: UIView) {
        contentView.addSubview(view)
    }

    public func add(_ viewController: UIViewController) {
        add(viewController.view)
    }
}


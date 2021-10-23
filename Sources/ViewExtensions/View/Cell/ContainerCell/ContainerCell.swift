//
//  ContainerCell.swift
//  ContainerCell
//
//  Created by Ilya Senchukov on 21.07.2021.
//

import UIKit

public class ContainerCell: UICollectionViewCell {

    public var size: CGSize? {
        didSet {
            guard let size = size else { return }
            (contentView.widthAnchor == size.width).isActive = true
            (contentView.heightAnchor == size.height).isActive = true
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


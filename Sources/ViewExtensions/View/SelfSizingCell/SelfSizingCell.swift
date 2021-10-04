//
//  SelfSizingCell.swift
//  SelfSizingCell
//
//  Created by Ilya Senchukov on 01.08.2021.
//

import UIKit

open class SelfSizingCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!

    public var maxWidth: CGFloat? {
        didSet {
            guard let maxWidth = maxWidth else {
                return
            }
            let widthConstraint = containerView.widthAnchor.constraint(equalToConstant: maxWidth)
            widthConstraint.priority = .defaultHigh
            widthConstraint.isActive = true
        }
    }

}

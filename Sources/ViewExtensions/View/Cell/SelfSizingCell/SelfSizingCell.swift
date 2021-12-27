//
//  SelfSizingCell.swift
//  SelfSizingCell
//
//  Created by Ilya Senchukov on 01.08.2021.
//

import UIKit

open class SelfSizingCell: UICollectionViewCell {

    private var maxWidthConstraint: NSLayoutConstraint?
    private var maxHeightConstraint: NSLayoutConstraint?

    public var maxWidth: CGFloat? {
        didSet {
            guard let maxWidth = maxWidth else {
                return
            }

            if var maxWidthConstraint = maxWidthConstraint {
                maxWidthConstraint == maxWidth
            } else {
                maxWidthConstraint = contentView.widthAnchor == maxWidth
                maxWidthConstraint?.priority = .defaultHigh
                maxWidthConstraint?.isActive = true
            }

        }
    }

    public var maxHeight: CGFloat? {
        didSet {
            guard let maxHeight = maxHeight else {
                return
            }

            if var maxHeightConstraint = maxHeightConstraint {
                maxHeightConstraint == maxHeight
            } else {
                maxHeightConstraint = contentView.heightAnchor == maxHeight
                maxHeightConstraint?.priority = .defaultHigh
                maxHeightConstraint?.isActive = true
            }

        }
    }

}

//
//  SelfSizingCell.swift
//  SelfSizingCell
//
//  Created by Ilya Senchukov on 01.08.2021.
//

import UIKit

open class SelfSizingCell: UICollectionViewCell {

    public var maxWidth: CGFloat? {
        didSet {
            guard let maxWidth = maxWidth else { return }

            contentView.widthAnchor.constraint(equalToConstant: maxWidth).isActive = true
        }
    }

}

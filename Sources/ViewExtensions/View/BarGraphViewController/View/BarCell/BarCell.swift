//
//  BarCell.swift
//  
//
//  Created by Ilya Senchukov on 17.10.2021.
//

import UIKit

class BarCell: UICollectionViewCell, ViewModelContainer {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var barViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!

    var viewModel: BarCellViewModel?

    var styleProvider: StyleProvider?

    var maxHeight: CGFloat? {
        didSet {
            update()
        }
    }

    func update() {

        guard let viewModel = viewModel,
              let maxHeight = maxHeight else {
            return
        }

        barViewHeightConstraint.constant = maxHeight
        layoutSubviews()

        titleLabel.text = viewModel.title
        valueLabel.text = viewModel.value
        barViewHeightConstraint.constant = barView.frame.height * viewModel.percentage

        styleProvider?.styleBar(barView)
        styleProvider?.styleValueLabel(valueLabel)
        styleProvider?.styleBarTitleLabel(titleLabel)

        layoutSubviews()
    }

}

struct BarCellViewModel: ViewModel {
    var title: String
    var value: String
    var percentage: CGFloat
}


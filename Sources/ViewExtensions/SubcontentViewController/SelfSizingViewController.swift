//
//  SelfSizingViewController.swift
//  Dyet
//
//  Created by Ilya Senchukov on 11.07.2021.
//

import UIKit

open class SelfSizingViewController: UIViewController {

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculatePreferredSize()
    }

    func calculatePreferredSize() {
        let targetSize = CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let newPreferredContentSize = view.systemLayoutSizeFitting(targetSize)

        if newPreferredContentSize != preferredContentSize {
            preferredContentSize = newPreferredContentSize
        }
    }

    open override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        calculatePreferredSize()
    }

}


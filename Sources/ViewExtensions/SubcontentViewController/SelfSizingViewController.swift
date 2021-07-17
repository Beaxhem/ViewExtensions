//
//  SelfSizingViewController.swift
//  Dyet
//
//  Created by Ilya Senchukov on 11.07.2021.
//

import UIKit

public class SelfSizingViewController: UIViewController {

    public override func viewDidLayoutSubviews() {
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

    public override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        calculatePreferredSize()
    }

}


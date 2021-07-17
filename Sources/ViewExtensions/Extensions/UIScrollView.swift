//
//  UIScrollView.swift
//  Dyet
//
//  Created by Ilya Senchukov on 17.07.2021.
//

import UIKit

public extension UIScrollView {

    func scrollToTop() {
        var newOffset = contentOffset
        newOffset.y = 0

        setContentOffset(newOffset, animated: false)
    }

    func stopScrolling() {
        isScrollEnabled = false
        isScrollEnabled = true
    }

}


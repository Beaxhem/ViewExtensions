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

    @objc func scrollToBottom(animated: Bool = true) {
        let contentHeight = contentSize.height
        let viewHeight = bounds.height
        setContentOffset(.init(x: 0, y: contentHeight - viewHeight + contentInset.bottom), animated: animated)
    }

    func stopScrolling() {
        isScrollEnabled = false
        isScrollEnabled = true
    }

}

public extension UICollectionView {

	func scrollToBottom(animated: Bool = true, duration: CGFloat = 0.3, completion: (() -> Void)? = nil) {
		func setContentOffset() {
			let contentHeight = collectionViewLayout.collectionViewContentSize.height
			let viewHeight = bounds.height
			if contentHeight > viewHeight {
				var contentOffset = contentOffset
				contentOffset.y = contentHeight - viewHeight + contentInset.bottom
				self.setContentOffset(contentOffset, animated: false)
			}
		}
		DispatchQueue.main.async {
			if animated {
				UIView.animate(withDuration: 0.2) {
					setContentOffset()
				} completion: { _ in
					completion?()
				}
			} else {
				setContentOffset()
				completion?()
			}
		}
    }

}

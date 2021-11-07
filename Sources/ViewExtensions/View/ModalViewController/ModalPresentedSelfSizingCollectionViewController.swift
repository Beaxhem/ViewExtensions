//
//  ModalPresentedSelfSizingCollectionViewController.swift
//  
//
//  Created by Ilya Senchukov on 04.10.2021.
//

import UIKit



open class ModalPresentedSelfSizingCollectionViewController: ModalPresentedCollectionViewController  {


    open override var contentHeight: CGFloat {
        _contentHeight ?? 0
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        modalViewController?.dragGestureRecognizer.delegate = self
        _collectionView.delegate = self
    }

}

extension ModalPresentedSelfSizingCollectionViewController: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let dragGestureRecognizer = modalViewController?.dragGestureRecognizer,
              dragGestureRecognizer == gestureRecognizer else {
                  return false
              }

        return _collectionView.contentOffset.y <= 0
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

extension ModalPresentedSelfSizingCollectionViewController: UICollectionViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let dragGestureRecognizer = modalViewController?.dragGestureRecognizer else {
            return
        }

        let offset = _collectionView.contentOffset.y
        let translation = dragGestureRecognizer.translation(in: view.superview).y
        if offset < 0 || translation > 0 {
            _collectionView.contentOffset.y = 0
        }
    }
}


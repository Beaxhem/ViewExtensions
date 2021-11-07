//
//  ModalPresentedCollectionViewController.swift
//  
//
//  Created by Ilya Senchukov on 07.11.2021.
//

import UIKit

open class ModalPresentedCollectionViewController: UIViewController, CollectionModalPresented {

    public var modalViewController: ModalViewController?

    open var _collectionView: UICollectionView! {
        nil
    }

    public var contentHeight: CGFloat? {
        didSet {
            modalViewController?.update()
        }
    }

    public var _contentHeight: CGFloat {
        contentHeight ?? 0
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentHeight = _collectionView.collectionViewLayout.collectionViewContentSize.height
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        modalViewController?.dragGestureRecognizer.delegate = self
        _collectionView.delegate = self
    }

}

extension ModalPresentedCollectionViewController: UIGestureRecognizerDelegate {

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

extension ModalPresentedCollectionViewController: UICollectionViewDelegate {

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


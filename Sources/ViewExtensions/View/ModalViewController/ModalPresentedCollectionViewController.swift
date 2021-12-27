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

    open var contentView: UIView? {
        nil
    }

    open var dimmingView: UIView? {
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

    public lazy var gestureDelegate: ModalCollectionViewDelegate = {
        let delegate = ModalCollectionViewDelegate()
        delegate.modalViewController = modalViewController
        delegate.collectionView = _collectionView
        return delegate
    }()

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentHeight = _collectionView.collectionViewLayout.collectionViewContentSize.height
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        modalViewController?.dragGestureRecognizer.delegate = gestureDelegate
        _collectionView.delegate = gestureDelegate
    }

}

public class ModalCollectionViewDelegate: NSObject, UIGestureRecognizerDelegate {

    public var modalViewController: ModalViewController?
    public weak var collectionView: UICollectionView?

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {

        guard let collectionView = collectionView,
              let dragGestureRecognizer = modalViewController?.dragGestureRecognizer,
              dragGestureRecognizer == gestureRecognizer else {
                  return false
              }
        return collectionView.contentOffset.y <= 0
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

extension ModalCollectionViewDelegate: UICollectionViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let modalViewController = modalViewController,
              let collectionView = collectionView else {
            return
        }

        let offset = collectionView.contentOffset.y
        let translation = modalViewController.dragGestureRecognizer.translation(in: collectionView.superview).y

        if offset < 0 || translation > 0 || modalViewController.topConstraint.constant > modalViewController.topSafeArea {
            collectionView.contentOffset.y = 0

        }
    }

    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        scrollView.scrollToTop()
    }
}

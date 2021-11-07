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

    var _contentHeight: CGFloat? {
        didSet {
            modalViewController?.update()
        }
    }

    public var contentHeight: CGFloat {
        _collectionView.contentSize.height
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _contentHeight = _collectionView.collectionViewLayout.collectionViewContentSize.height
    }

}

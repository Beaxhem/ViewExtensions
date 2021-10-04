//
//  CollectionModalPresented.swift
//  
//
//  Created by Ilya Senchukov on 04.10.2021.
//

import UIKit

public protocol CollectionModalPresented: ModalPresented, UIGestureRecognizerDelegate {

    var _collectionView: UICollectionView! { get set }

}

//
//  SupplementaryView.swift
//  
//
//  Created by Ilya Senchukov on 27.12.2021.
//

import UIKit

public protocol SupplementaryView: CaseIterable, RawRepresentable {

    var viewType: UICollectionReusableView.Type { get }

}

public protocol SupplementaryViewProvider {
    associatedtype View: SupplementaryView
}

public extension SupplementaryViewProvider where View.RawValue == String {

    func register(collectionView: UICollectionView, bundle: Bundle? = nil) {
        for kind in View.allCases {
            let nib = UINib(nibName: kind.viewType.reuseIdentifier, bundle: bundle)
            collectionView.register(nib,
                                    forSupplementaryViewOfKind: kind.rawValue,
                                    withReuseIdentifier: kind.viewType.reuseIdentifier)
        }
    }

}

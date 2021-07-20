//
//  UICollectionView.swift
//  Dyet
//
//  Created by Ilya Senchukov on 17.07.2021.
//

import UIKit

public extension UICollectionView {

    func register<T: UICollectionViewCell>(_ cell: T.Type, bundle: Bundle) {
        register(
            UINib(nibName: cell.reuseIdentifier, bundle: bundle),
            forCellWithReuseIdentifier: cell.reuseIdentifier
        )
    }

    func dequeCell<T: UICollectionViewCell>(_ cell: T.Type, indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }

}

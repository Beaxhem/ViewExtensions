//
//  UICollectionView.swift
//  Dyet
//
//  Created by Ilya Senchukov on 17.07.2021.
//

import UIKit

public extension UICollectionView {

    typealias ViewModelContainingCell = UICollectionViewCell & ViewModelContainer
    typealias ViewModelContainerController = UIViewController & ViewModelContainer

    func registerCell<T: UICollectionViewCell>(_ cell: T.Type) {
        register(cell, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }

    func register<T: UICollectionViewCell>(_ cell: T.Type, bundle: Bundle? = nil) {
        register(
            UINib(nibName: cell.reuseIdentifier, bundle: bundle ?? .module),
            forCellWithReuseIdentifier: cell.reuseIdentifier
        )
    }

    func dequeueCell<T: UICollectionViewCell>(_ cell: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }

    func dequeueCell<T: ViewModelContainingCell>(_ cell: T.Type, viewModel: T.VM, for indexPath: IndexPath) -> T {
        var cell = dequeueCell(T.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }

    func dequeueContainerCell<T: UIViewController>(with vc: T, for indexPath: IndexPath) -> ContainerCell {
        let cell = dequeueCell(ContainerCell.self, for: indexPath)
        cell.add(vc)
        return cell
    }

    func dequeueContainerCell<T: ViewModelContainerController>(with vc: T, viewModel: T.VM, for indexPath: IndexPath) -> ContainerCell {
        var mutableVc = vc
        mutableVc.viewModel = viewModel
        return dequeueContainerCell(with: mutableVc, for: indexPath)
    }
}

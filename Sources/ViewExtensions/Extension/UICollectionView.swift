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

    func register<T: UICollectionViewCell>(_ nibCell: T.Type, bundle: Bundle? = nil) {
        register(
            UINib(nibName: nibCell.reuseIdentifier, bundle: bundle),
            forCellWithReuseIdentifier: nibCell.reuseIdentifier
        )
    }

    func register(nibs: UICollectionViewCell.Type..., bundle: Bundle? = nil) {
        nibs.forEach {
            register($0, bundle: bundle)
        }
    }

    func register<T: UICollectionReusableView>(_ view: T.Type, kind: String, bundle: Bundle? = nil) {
        register(UINib(nibName: T.reuseIdentifier, bundle: bundle), forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
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

    @available(*, deprecated, message: "Use dequeueSupplementaryView() instead")
    func dequeueHeader<T: UICollectionReusableView>(_ supplementaryView: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }

    func dequeueSupplementaryView<T: UICollectionReusableView>(_ supplementaryView: T.Type, kind: String = UICollectionView.elementKindSectionHeader, indexPath: IndexPath) -> T {
        dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }

    typealias ViewModelContainingSupplementaryView = UICollectionReusableView & ViewModelContainer

    func dequeueSupplementaryView<T: ViewModelContainingSupplementaryView>(
        _ supplementaryView: T.Type,
        kind: String = UICollectionView.elementKindSectionHeader,
        viewModel: T.VM,
        indexPath: IndexPath) -> T {
            var view = dequeueSupplementaryView(T.self, kind: kind, indexPath: indexPath)
            view.viewModel = viewModel
            return view
        }

}

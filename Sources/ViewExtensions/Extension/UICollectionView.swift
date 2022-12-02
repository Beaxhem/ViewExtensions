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

	/// Register UICollectionViewCell
    func registerCell<T: UICollectionViewCell>(_ cell: T.Type) {
        register(cell, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }

	/// Register nib for UICollectionViewCell
    func register(_ nibs: UICollectionViewCell.Type..., bundle: Bundle? = nil) {
        nibs.forEach { nibCell in
            register(
                UINib(nibName: nibCell.reuseIdentifier, bundle: bundle),
                forCellWithReuseIdentifier: nibCell.reuseIdentifier
            )
        }
    }

	/// Register reusable view (header, footer, etc)
    func register(supplementary: UICollectionReusableView.Type, kind: String? = nil, bundle: Bundle? = nil) {
        register(UINib(nibName: supplementary.reuseIdentifier,
                       bundle: bundle),
                 forSupplementaryViewOfKind: kind ?? supplementary.reuseIdentifier,
                 withReuseIdentifier: supplementary.reuseIdentifier)
    }

	/// Register multiple reusable views (headers, footers, etc)
    func register(views: UICollectionReusableView.Type..., bundle: Bundle? = nil) {
        for view in views {
            register(supplementary: view, bundle: bundle)
        }
    }

    func dequeueCell<T: UICollectionViewCell>(_ cell: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: cell.reuseIdentifier, for: indexPath) as! T
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

    func dequeueSupplementaryView<T: UICollectionReusableView>(_ supplementaryView: T.Type, kind: String? = nil, indexPath: IndexPath) -> T {
        dequeueReusableSupplementaryView(ofKind: kind ?? supplementaryView.reuseIdentifier,
										 withReuseIdentifier: supplementaryView.reuseIdentifier,
										 for: indexPath) as! T
    }

    typealias ViewModelContainingSupplementaryView = UICollectionReusableView & ViewModelContainer

    func dequeueSupplementaryView<T: ViewModelContainingSupplementaryView>(
        _ supplementaryView: T.Type,
        kind: String = T.reuseIdentifier,
        viewModel: T.VM,
        indexPath: IndexPath) -> T {
            var view = dequeueSupplementaryView(T.self, kind: kind, indexPath: indexPath)
            view.viewModel = viewModel
            return view
        }

}

public extension UICollectionView {

	func supplementaryView<T: UICollectionReusableView>(ofType: T.Type, at indexPath: IndexPath) -> T? {
		supplementaryView(forElementKind: T.reuseIdentifier, at: indexPath) as? T
	}

}

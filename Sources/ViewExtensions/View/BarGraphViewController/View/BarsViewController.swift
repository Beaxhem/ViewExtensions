//
//  BarsViewController.swift
//  
//
//  Created by Ilya Senchukov on 17.10.2021.
//

import UIKit

class BarsViewController: UIViewController {

    static func create(data: [BarData], styleProvider: BarChartStyleProvider? = nil) -> BarsViewController {
        let vc = BarsViewController()
        vc.data = data
        vc.styleProvider = styleProvider
        return vc
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = Constants.interItemSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    var data: [BarData]!
    var styleProvider: BarChartStyleProvider?

    private var interItemSpacing: CGFloat {
        styleProvider?.barsInterItemSpacing().value ?? Constants.interItemSpacing
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        view.fit(collectionView)

        collectionView.register(BarCell.self, bundle: .module)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.reloadData()
    }

}

extension BarsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let data = data[indexPath.item]
        let viewModel = BarCellViewModel(title: data.label,
                                         value: data.value,
                                         percentage: .random(in: 0...100) / 100)

        let cell = collectionView.dequeueCell(BarCell.self, viewModel: viewModel, for: indexPath)
        cell.styleProvider = styleProvider
        cell.maxHeight = collectionView.frame.height

        return cell
    }

}

extension BarsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: (collectionView.frame.width - CGFloat(data.count - 1) * interItemSpacing) / CGFloat(data.count),
              height: collectionView.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        interItemSpacing
    }
}

private extension BarsViewController {

    enum Constants {
        static let interItemSpacing: CGFloat = 15
    }
}

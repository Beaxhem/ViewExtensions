//
//  BarsViewController.swift
//  
//
//  Created by Ilya Senchukov on 17.10.2021.
//

import UIKit

class BarsViewController: UIViewController {

    static func create(data: [BarData]) -> BarsViewController {
        let vc = BarsViewController()
        vc.data = data
        return vc
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    var data: [BarData]!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        view.fit(collectionView)

        collectionView.register(BarCell.self, bundle: .module)
        collectionView.layoutSubviews()
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
        cell.maxHeight = collectionView.frame.height
        return cell
    }

}

extension BarsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: (collectionView.frame.width / 7) - 10,
              height: collectionView.frame.height)
    }

}

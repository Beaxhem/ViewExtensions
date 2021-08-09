//
//  PagedSubcontentViewController.swift
//  PagedSubcontentViewController
//
//  Created by Ilya Senchukov on 07.08.2021.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift

open class PagedSubcontentViewController: UIViewController {

    @IBOutlet weak var topContentHeightConstraint: NSLayoutConstraint!
    @IBOutlet public weak var topContentContainerView: UIView!
    @IBOutlet public weak var collectionView: UICollectionView!

    public var topContent: UIViewController!
    public let pages = PublishRelay<[UIViewController]>()

    private var _disposeBag: DisposeBag?
    private var topContentContainer: UIViewController!
    private lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<PagedSection>(
        configureCell: { _, collectionView, indexPath, item in
            collectionView.dequeueContainerCell(with: item, for: indexPath)
        }
    )

    public init() {
        super.init(nibName: PagedSubcontentViewController.reuseIdentifier, bundle: .module)
    }

    required public init?(coder: NSCoder) {
        super.init(nibName: PagedSubcontentViewController.reuseIdentifier, bundle: .module)
    }

    open override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)

        if (container as? SelfSizingViewController) != nil {
            topContentHeightConstraint?.constant = container.preferredContentSize.height
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        _setupView()
        _setupBindings()
    }

    open func getTopContent() -> UIViewController {
        fatalError()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = collectionView.frame.size
        }
    }

}

private extension PagedSubcontentViewController {

    func _setupView() {
        view.backgroundColor = .red

        topContentContainer = SelfSizingViewController()
        topContentContainer.move(to: self, viewPath: \.topContentContainerView)
        topContentContainer.view.fit(into: topContentContainerView)

        topContent = getTopContent()
        topContent.move(to: topContentContainer)
        topContent.view.fit(into: topContentContainer.view)

        collectionView.registerCell(ContainerCell.self)
        collectionView.layer.cornerRadius = 26
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collectionView.layer.masksToBounds = true

        view.forceLayout()
    }

    func _setupBindings() {

        _disposeBag = DisposeBag {

            pages
                .map { [PagedSection.init(items: $0)] }
                .bind(to: collectionView.rx.items(dataSource: dataSource))

            collectionView.rx
                .didScroll
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { owner, _ in

                let offset = owner.collectionView.contentOffset.x

                if offset < 0 {
                    var newOffset = owner.collectionView.contentOffset
                    newOffset.x = 0
                    owner.collectionView.setContentOffset(newOffset, animated: false)
                } else if offset > owner.collectionView.contentSize.width {
                    var newOffset = owner.collectionView.contentOffset
                    newOffset.x = owner.collectionView.contentSize.width
                    owner.collectionView.setContentOffset(newOffset, animated: false)
                }
            })

        }

    }

}

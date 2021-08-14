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
    @IBOutlet weak var pagedView: HorizontalPagedView!

    public var topContent: UIViewController!
    public let pages = PublishRelay<[UIViewController]>()

    private var _disposeBag: DisposeBag?
    private var topContentContainer: UIViewController!
    private lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<PagedSection>(
        animationConfiguration: .init(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .none),
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

        guard let container = container as? SelfSizingViewController else { return }
        topContentHeightConstraint?.constant = container.preferredContentSize.height
        pagedView.didChangeSize()
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
        pagedView.start()
    }

}

private extension PagedSubcontentViewController {

    func _setupView() {
        pagedView.parent = self

        topContentContainer = SelfSizingViewController()
        topContentContainer.move(to: self, viewPath: \.topContentContainerView)
        topContentContainer.view.fit(into: topContentContainerView)

        topContent = getTopContent()
        topContent.move(to: topContentContainer)
        topContent.view.fit(into: topContentContainer.view)

        pagedView.layer.cornerRadius = 26
        pagedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        pagedView.layer.masksToBounds = true
        pagedView.isScrollEnabled = false

        view.forceLayout()
    }

    func _setupBindings() {

        _disposeBag = DisposeBag {

            pages
                .compactMap { $0 }
                .subscribe(with: self, onNext: { owner, pages in
                    owner.pagedView.addPages(pages)
                })

        }

    }

}

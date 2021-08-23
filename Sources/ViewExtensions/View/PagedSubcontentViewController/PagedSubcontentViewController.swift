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
    @IBOutlet weak var mainContentContainerView: UIView!

    public var topContent: UIViewController!
    public lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.dataSource = self
        return vc
    }()

    private lazy var animationController = PageViewAnimationController(pageViewController: pageViewController, scrollView: scrollView)

    private var _disposeBag: DisposeBag?
    private var topContentContainer: UIViewController!

    private var scrollView: UIScrollView {
        pageViewController.view.subviews.first as! UIScrollView
    }

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

        pageViewController.viewControllers?.forEach { viewController in
            viewController.view.frame.size.height = mainContentContainerView.frame.height
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        _setupView()
        setupAnimation()
    }

    open func getTopContent() -> UIViewController {
        fatalError()
    }

}

private extension PagedSubcontentViewController {

    func _setupView() {
        setupTopContent()
        setupMainContent()

        view.forceLayout()
    }

    func setupTopContent() {
        topContentContainer = SelfSizingViewController()
        topContentContainer.move(to: self, viewPath: \.topContentContainerView)
        topContentContainer.view.fit(into: topContentContainerView)

        topContent = getTopContent()
        topContent.move(to: topContentContainer)
        topContent.view.fit(into: topContentContainer.view)
    }

    func setupMainContent() {
        mainContentContainerView.layer.cornerRadius = 26
        mainContentContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mainContentContainerView.layer.masksToBounds = true

        pageViewController.move(to: self)
        mainContentContainerView.addSubview(pageViewController.view)
        pageViewController.view.fit(into: mainContentContainerView)
    }

}

private extension PagedSubcontentViewController {

    @objc func handleGesture(gesture: UIPanGestureRecognizer) {
        guard gesture.state == .began else { return }
        animationController.touchBegan.accept(())
    }


    func setupAnimation() {
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(handleGesture))

        animationController.animation = { [weak self] controller in
            let backgroundColor: UIColor = controller.view.backgroundColor ?? .systemBackground
            self?.view.backgroundColor = backgroundColor
        }
    }

}

extension PagedSubcontentViewController: UIPageViewControllerDataSource {

    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        fatalError("Not implemented")
    }

    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        fatalError("Not implemented")
    }

}

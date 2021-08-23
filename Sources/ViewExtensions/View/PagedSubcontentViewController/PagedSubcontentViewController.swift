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
        vc.delegate = self
        vc.dataSource = self
        return vc
    }()

    private var _disposeBag: DisposeBag?
    private var topContentContainer: UIViewController!

    private let touchBegan = PublishRelay<Void>()
    private let transitionToRelay = PublishRelay<[UIViewController]>()
    private let transitionDirection = PublishRelay<ScrollDirection>()

    private lazy var propertyAnimator: UIViewPropertyAnimator = {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
        return animator
    }()
    private var scrollView: UIScrollView {
        pageViewController.view.subviews.first as! UIScrollView
    }
    private var translationX: CGFloat {
        let translation = scrollView.panGestureRecognizer.translation(in: mainContentContainerView).x
        return abs(translation)
    }
    var scrollFraction: CGFloat {
        translationX / mainContentContainerView.frame.width
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
        _setupBindings()
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

    @objc func test(gesture: UIPanGestureRecognizer) {
        guard gesture.state == .began else { return }
        touchBegan.accept(())

    }

    func dismissGesture() {
        scrollView.panGestureRecognizer.isEnabled = false
        scrollView.panGestureRecognizer.isEnabled = true
    }

    func dismissGestureAndContinue() {
        dismissGesture()
        propertyAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    }

    func _setupBindings() {
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(test))

        _disposeBag = DisposeBag {

            touchBegan
                .subscribe(with: self, onNext: { owner, direction in
                    guard owner.propertyAnimator.fractionComplete != 0 || owner.propertyAnimator.state == .active else {
                        return
                    }
                    owner.dismissGestureAndContinue()
                })

            transitionToRelay
                .compactMap { $0.first }
                .subscribe(with: self, onNext: { owner, controller in
                    let backgroundColor: UIColor = controller.view.backgroundColor ?? .systemBackground
                    owner.propertyAnimator.addAnimations {
                        owner.view.backgroundColor = backgroundColor
                    }
                    owner.propertyAnimator.pauseAnimation()
                    if owner.scrollView.panGestureRecognizer.state == .possible {
                        owner.propertyAnimator.continueAnimation(withTimingParameters: nil,
                                                                 durationFactor: owner.scrollFraction)
                    }
                })

            scrollView.rx
                .didScroll
                .withLatestFrom(transitionToRelay.compactMap { $0.first })
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(with: self, onNext: { owner, controller in
                    let currentViewController = owner.pageViewController.viewControllers!.first!
                    let controllerHasChanged = currentViewController != controller
                    let animatorState = owner.propertyAnimator.state
                    let gestureState = owner.scrollView.panGestureRecognizer.state

                    if (animatorState == .active || gestureState == .began) && !controllerHasChanged {
                        owner.dismissGestureAndContinue()
                    } else if owner.scrollView.panGestureRecognizer.state == .changed {
                        owner.propertyAnimator.fractionComplete = owner.scrollFraction
                    }
                })

            scrollView.rx.willEndDragging
                .withLatestFrom(transitionDirection)
                .subscribe(with: self, onNext: { owner, initialDirection in
                    let velocity = owner.scrollView.panGestureRecognizer.velocity(in: owner.mainContentContainerView).x
                    let currentScrollDirection: ScrollDirection = velocity < 0 ? .right : .left

                    var isReversed = !(abs(velocity) > 300 || owner.translationX >= owner.scrollView.frame.width / 2)

                    let scrollDirectionHasChanged = currentScrollDirection != initialDirection
                    isReversed = isReversed || scrollDirectionHasChanged

                    owner.propertyAnimator.isReversed = isReversed
                    owner.propertyAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                })

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

extension PagedSubcontentViewController: UIPageViewControllerDelegate {

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: mainContentContainerView).x
        transitionToRelay.accept(pendingViewControllers)
        transitionDirection.accept(velocity < 0 ? .right : .left)
    }

}

enum ScrollDirection {
    case left
    case right
}


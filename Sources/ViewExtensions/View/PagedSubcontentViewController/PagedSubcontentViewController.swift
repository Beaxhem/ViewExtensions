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

extension ObservableType {

    func withPrevious() -> Observable<(Element?, Element)> {
        scan([]) { Array($0 + [$1]).suffix(2) }
            .map { ($0.count > 1 ? $0.first : nil, $0.last!) }
    }
}

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

    private lazy var propertyAnimator: UIViewPropertyAnimator = {
        .init(duration: 0.5, curve: .easeInOut)
    }()
    private var scrollView: UIScrollView {
        pageViewController.view.subviews.first as! UIScrollView
    }
    private var translationX: CGFloat {
        let translation = scrollView.panGestureRecognizer.translation(in: mainContentContainerView).x

        return translation < 0 ? -translation : translation
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

extension UIViewAnimatingState: CustomStringConvertible {

    public var description: String {
        switch self {
            case .stopped:
                return "stopped"
            case .inactive:
                return "inactive"
            case .active:
                return "active"
        }
    }

}

extension UIGestureRecognizer.State: CustomStringConvertible {

    public var description: String {
        switch self {
            case .possible:
                return "possible"
            case .failed:
                return "failed"
            case .cancelled:
                return "cancelled"
            case .began:
                return "began"
            case .changed:
                return "changed"
            case .ended:
                return "ended"
        }
    }

}

extension UIViewAnimatingPosition: CustomStringConvertible {

    public var description: String {
        switch self {
            case .current:
                return "current"
            case .end:
                return "end"
            case .start:
                return "start"
        }
    }

}

private extension PagedSubcontentViewController {

    @objc func test(gesture: UIPanGestureRecognizer) {
        guard gesture.state == .began else { return }
        touchBegan.accept(())

    }

    func _setupBindings() {
        scrollView.panGestureRecognizer.delaysTouchesBegan = true
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(test))

        _disposeBag = DisposeBag {

            touchBegan
                .subscribe(with: self, onNext: { owner, _ in
                    print("touch began", owner.propertyAnimator.state)
                    if owner.propertyAnimator.fractionComplete != 0 || owner.propertyAnimator.state == .active {
                        print("fraction != 0")
//                        owner.propertyAnimator.stopAnimation(false)
//                        owner.propertyAnimator.finishAnimation(at: .end)
                        owner.scrollView.panGestureRecognizer.isEnabled = false
                        owner.scrollView.panGestureRecognizer.isEnabled = true
                        owner.propertyAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                    }
                })

            transitionToRelay
                .compactMap { $0.first }
                .subscribe(with: self, onNext: { owner, controller in
                    let backgroundColor: UIColor = controller.view.backgroundColor ?? .systemBackground
                    owner.propertyAnimator.addAnimations {
                        owner.view.backgroundColor = backgroundColor
                    }
                })

            scrollView.rx
                .didScroll
                .withLatestFrom(transitionToRelay.compactMap { $0.first })
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(with: self, onNext: { owner, controller in
                    print("scroll")
                    if owner.propertyAnimator.state == .active &&
                        controller == owner.pageViewController.viewControllers!.first! {
                        print("disable if", owner.scrollView.panGestureRecognizer.state)
                        owner.scrollView.panGestureRecognizer.isEnabled = false
                        owner.scrollView.panGestureRecognizer.isEnabled = true
                        owner.propertyAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                    } else if owner.scrollView.panGestureRecognizer.state == .changed {
                        print("changed")
                        owner.propertyAnimator.fractionComplete = owner.scrollFraction
                    } else {

                        print("disable else", owner.scrollView.panGestureRecognizer.state)
//                        owner.scrollView.panGestureRecognizer.isEnabled = false
//                        owner.scrollView.panGestureRecognizer.isEnabled = true
//                        owner.propertyAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                    }

                })

            scrollView.rx.willEndDragging
                .withLatestFrom(transitionToRelay.compactMap { $0.first })
                .subscribe(with: self, onNext: { owner, latest in
                    var velocity = owner.scrollView.panGestureRecognizer.velocity(in: owner.mainContentContainerView).x
                    if velocity < 0 { velocity *= -1 }

                    if owner.scrollView.panGestureRecognizer.isEnabled {
                        print("will end", !(velocity > 300 || owner.translationX >= owner.scrollView.frame.width / 2))
                        owner.propertyAnimator.isReversed = !(velocity > 300 || owner.translationX >= owner.scrollView.frame.width / 2)
                        owner.propertyAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                    }

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
        transitionToRelay.accept(pendingViewControllers)
    }

}


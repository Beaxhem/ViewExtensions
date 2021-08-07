//
//  File.swift
//  File
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
    @IBOutlet public weak var mainContentContainerView: UIView!

    public var topContent: UIViewController!

    private var topContentContainer: UIViewController!
    private var pageViewController: UIPageViewController = .init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

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

    public override func viewDidLoad() {
        super.viewDidLoad()
        pageViewController.dataSource = self
        setupView()
    }

    open func getTopContent() -> UIViewController {
        fatalError()
    }

}

extension PagedSubcontentViewController {

    public func setViewController(
        _ vc: UIViewController,
        direction: UIPageViewController.NavigationDirection = .forward,
        animated: Bool = true
    ) {
        pageViewController.setViewControllers([vc], direction: direction, animated: animated, completion: nil)
    }

}

private extension PagedSubcontentViewController {

    func setupView() {

        topContentContainer = SelfSizingViewController()
        topContentContainer.move(to: self, viewPath: \.topContentContainerView)
        topContentContainer.view.fit(into: topContentContainerView)

        topContent = getTopContent()
        topContent.move(to: topContentContainer)
        topContent.view.fit(into: topContentContainer.view)

        pageViewController.move(to: self, viewPath: \.mainContentContainerView)
        pageViewController.view.fit(into: mainContentContainerView)
        
        mainContentContainerView.layer.cornerRadius = 26
        mainContentContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mainContentContainerView.layer.masksToBounds = true

        view.forceLayout()
    }

}

extension PagedSubcontentViewController: UIPageViewControllerDataSource {

    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        fatalError("viewControllerBefore is not implemented")
    }

    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        fatalError("viewControllerAfter is not implemented")
    }

}

//
//  MedicinesViewController.swift
//  Dyet
//
//  Created by Ilya Senchukov on 09.07.2021.
//

import UIKit
import RxSwift
import RxDataSources

public enum TopViewState {
    case compact
    case full

    public func toggle() -> TopViewState {
        self == .compact ? .full : .compact
    }
}

open class SubcontentViewController: UIViewController {

    private static let animationDuration: TimeInterval = 0.2

    @IBOutlet public weak var pageContainer: UIView!
    @IBOutlet public weak var collectionView: UICollectionView!
    @IBOutlet public weak var topView: UIView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!

    private var container: UIViewController!
    private var isTopReached = false

    public var topViewContent: TopReachObserving!
    public var disposeBag: DisposeBag?
    public var backgroundColor: UIColor? {
        didSet {
            pageContainer.backgroundColor = backgroundColor
        }
    }
    open var isScrollObserving: Bool {
        false
    }

    public init() {
        super.init(nibName: SubcontentViewController.reuseIdentifier, bundle: .module)
    }

    required public init?(coder: NSCoder) {
        super.init(nibName: SubcontentViewController.reuseIdentifier, bundle: .module)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        setupCollectionView()
        setupMenu()
        setupBindings()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIWindow.keyboardWillHideNotification, object: nil)
    }

    open override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)

        if (container as? SelfSizingViewController) != nil {
            topViewHeightConstraint == container.preferredContentSize.height
        }
    }

    open func getTopView() -> TopReachObserving {
        fatalError("Not implemented method 'topView(for:)'")
    }

}

private extension SubcontentViewController {

    func setupCollectionView() {
        collectionView.alwaysBounceVertical = true
        collectionView.layer.cornerRadius = 26
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    func setupMenu() {
        topView.translatesAutoresizingMaskIntoConstraints = false

        container = SelfSizingViewController()
        container.move(to: self, viewPath: \.topView)
        container.view.fit(topView)

        topViewContent = getTopView()
        topViewContent.move(to: container)
        topViewContent.view.fit(container.view)

        view.forceLayout()
    }

    func setupBindings() {

        disposeBag = DisposeBag {

            collectionView
                .rx
                .didScroll
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(
                    with: self,
                    onNext: { owner, _ in
                        guard owner.isScrollObserving else {
                            return
                        }

                        let updateState: (TopViewState) -> () = {
                            if let state = try? owner.topViewContent.topReachState.value(),
                               state != $0 {
                                owner.topViewContent.topReachState.onNext($0)
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        }

                        let offset = owner.collectionView.contentOffset.y
                        if offset < 0 {
                            owner.collectionView.scrollToTop()

                            if owner.isTopReached {
                                updateState(.full)

                            } else {
                                owner.isTopReached = true
                            }
                        } else if offset > 0 {
                            if owner.isTopReached,
                               let state = try? owner.topViewContent.topReachState.value(),
                               state == .full {
                                owner.collectionView.scrollToTop()
                                owner.collectionView.stopScrolling()
                                updateState(.compact)
                            }

                            owner.isTopReached = false
                        }
                    }
                )
        }

    }

}

extension SubcontentViewController {

    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            collectionView.contentInset.bottom = view.frame.height - keyboardHeight.origin.y
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        collectionView.contentInset.bottom = 0
    }

}

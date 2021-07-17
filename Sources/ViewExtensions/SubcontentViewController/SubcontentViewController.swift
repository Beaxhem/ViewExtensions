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
}

open class SubcontentViewController: UIViewController {

    private static let animationDuration: TimeInterval = 0.2

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!

    private var container: UIViewController!
    private var topViewContent: TopReachObserving!
    private var isTopReached = false

    var disposeBag: DisposeBag?

    init() {
        super.init(nibName: SubcontentViewController.reuseIdentifier, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true

        collectionView.layer.cornerRadius = 26
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        setupMenu()
        setupBindings()
    }

    public override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)

        if (container as? SelfSizingViewController) != nil {
            topViewHeightConstraint?.constant = container.preferredContentSize.height
        }
    }

    func getTopView() -> TopReachObserving {
        fatalError("Not implemented method 'topView(for:)'")
    }

}

private extension SubcontentViewController {

    func setupMenu() {
        topView.translatesAutoresizingMaskIntoConstraints = false

        container = SelfSizingViewController()
        container.move(to: self, viewPath: \.topView)
        container.view.fit(into: topView)

        topViewContent = self.getTopView()
        self.topViewContent.move(to: self.container)
        self.topViewContent.view.fit(into: self.container.view)

        self.view.forceLayout()
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

                        let updateState: (TopViewState) -> () = {
                            if owner.topViewContent.topReachState != $0 {
                                owner.topViewContent.topReachState = $0
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
                            if owner.isTopReached {
                                owner.collectionView.scrollToTop()
                                owner.collectionView.stopScrolling()
                                owner.isTopReached = false
                                updateState(.compact)
                            }

                        }
                    }
                )
        }

    }

}


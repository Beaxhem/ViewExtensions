//
//  PageViewAnimationController.swift
//  File
//
//  Created by Ilya Senchukov on 24.08.2021.
//

import RxDataSources
import RxCocoa
import RxSwift
import UIKit

public class PageViewAnimationController: NSObject {

    public enum ScrollDirection {
        case left
        case right
    }

    public var pageViewController: UIPageViewController
    public var scrollView: UIScrollView

    public var animation: ((UIViewController) -> Void)?

    public let touchBegan = PublishRelay<Void>()
    public let transitionToRelay = PublishRelay<[UIViewController]>()
    public let transitionDirection = PublishRelay<ScrollDirection>()

    private var disposeBag: DisposeBag?

    private lazy var propertyAnimator: UIViewPropertyAnimator = {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
        return animator
    }()

    private var translationX: CGFloat {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView).x
        return abs(translation)
    }

    public var scrollFraction: CGFloat {
        translationX / scrollView.frame.width
    }

    init(pageViewController: UIPageViewController, scrollView: UIScrollView) {
        self.pageViewController = pageViewController
        self.scrollView = scrollView
        super.init()

        self.pageViewController.delegate = self
        setupBindings()
    }

}

private extension PageViewAnimationController {

    func dismissGesture() {
        scrollView.panGestureRecognizer.isEnabled = false
        scrollView.panGestureRecognizer.isEnabled = true
    }

    func dismissGestureAndContinue() {
        dismissGesture()
        propertyAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    }

    func setupBindings() {

        disposeBag = DisposeBag {

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
                    owner.propertyAnimator.addAnimations {
                        owner.animation?(controller)
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
                    guard let currentViewController = owner.pageViewController.viewControllers?.first else {
                        return
                    }

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
                    let velocity = owner.scrollView.panGestureRecognizer.velocity(in: owner.scrollView).x
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

extension PageViewAnimationController: UIPageViewControllerDelegate {

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView).x
        transitionToRelay.accept(pendingViewControllers)
        transitionDirection.accept(velocity < 0 ? .right : .left)
    }

}


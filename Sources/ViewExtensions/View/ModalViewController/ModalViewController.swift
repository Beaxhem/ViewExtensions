//
//  ModalViewController.swift
//  
//
//  Created by Ilya Senchukov on 26.09.2021.
//

import UIKit

public class ModalViewController: UIViewController {

    public static func present(in parent: UIViewController,
                               controller: ModalPresented,
                               contentInsets: UIEdgeInsets? = nil,
                               animationDuration: TimeInterval = 0.3) -> ModalViewController {

        let modalViewController = ModalViewController()

        controller.modalViewController = modalViewController
        modalViewController.dimmingView = controller.dimmingView ?? Self.defaultDimmingView
        modalViewController.contentView = controller.contentView ?? Self.defaultContentView
        modalViewController.contentInsets = contentInsets ?? Self.defaultContentInsets
        modalViewController.animationDuration = animationDuration
        modalViewController.rootViewController = controller

        modalViewController.beginAppearanceTransition(true, animated: true)
        modalViewController.moveAndFit(to: parent.navigationController ?? parent)
        
        return modalViewController
    }

    private static var defaultContentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .systemBackground
        contentView.clipsToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner],
                                 radius: Constants.cornerRadius)
        return contentView
    }()

    private static var defaultDimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.2)
        return view
    }()

    private static let defaultContentInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

    public lazy var maxHeight: CGFloat = view.frame.height - topSafeArea

    public var isAnimating = false

    private lazy var dragIndicator: UIView = {
        let dragIndicator = UIView()
        dragIndicator.backgroundColor = .lightGray
        dragIndicator.layer.cornerRadius = 2.5
        dragIndicator.translatesAutoresizingMaskIntoConstraints = false
        return dragIndicator
    }()

    private lazy var dismissTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissModal))

    public lazy var dragGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onDrag))

    public weak var rootViewController: ModalPresented!
    
    public weak var delegate: ModalViewDelegate?

    private var dimmingView: UIView!

    private var contentView: UIView!

    private var animationDuration: TimeInterval!

    private var initialTopOffset: CGFloat = 0

    private var rootViewControllerContraints: Constraints?

    private var contentViewConstraints: Constraints?

    private var dragIndicatorConstraints: Constraints?

    public var contentInsets: UIEdgeInsets! {
        didSet {
            guard let _ = rootViewControllerContraints else { return }
            update()
        }
    }

    public var topOffset: CGFloat {
        contentViewConstraints!.topConstraint!.constant
    }

    public var isLocked: Bool = false {
        didSet {
            dragGestureRecognizer.isEnabled = !isLocked
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.masksToBounds = true
        setupView()
        setupConstraints()
        dimmingView.addGestureRecognizer(dismissTapGestureRecognizer)
        rootViewController.view.addGestureRecognizer(dragGestureRecognizer)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissModal()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showModal()
    }

    func setupView() {
        view.addSubview(dimmingView)
        view.fit(dimmingView)
        view.addSubview(contentView)
        rootViewController?.move(to: self, viewPath: \.contentView)
        view.addSubview(dragIndicator)
    }

}

public extension ModalViewController {

    func update(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.setupConstraints()
                self?.view.layoutIfNeeded()
            }
        } else {
            setupConstraints()
        }
    }

    func showModal() {
        dimmingView.layer.opacity = 0
        contentViewConstraints?.update(top: view.frame.height)
        view.layoutIfNeeded()
        isAnimating = true
        UIView.springAnimation(duration: animationDuration) { [weak self] in
            guard let self = self else { return }
            self.contentViewConstraints?.update(top: self.initialTopOffset)
            self.dimmingView.layer.opacity = 1
            self.view.layoutIfNeeded()
        } completion: { [weak self] in
            self?.isAnimating = false
            self?.endAppearanceTransition()
        }
    }

    @objc func dismissModal() {
        isAnimating = true
        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let self = self else { return }
            self.contentViewConstraints?.update(top: self.view.frame.height)
            self.dimmingView.layer.opacity = 0
            self.view.layoutIfNeeded()
        } completion: { [weak self] tset in
            self?.isAnimating = false
            self?.rootViewController.remove()
            self?.rootViewController = nil
            self?.willMove(toParent: nil)
            self?.remove()
        }
    }

    @objc func onDrag(sender: UIPanGestureRecognizer) {
        switch sender.state {
            case .began:
                initialTopOffset = contentViewConstraints!.topConstraint!.constant
            case .changed:
                let translationY = sender.translation(in: view).y / 2
                let newOffset = initialTopOffset + translationY
                contentViewConstraints?.update(top: max(newOffset, topSafeArea))
                delegate?.didScroll?(offsetY: translationY)
            case .ended:
                let translationY = sender.translation(in: view).y
                let velocityY = sender.velocity(in: view).y
                if translationY > rootViewController.view.frame.height / 2
                    || (velocityY > Constants.dismissVelocity && translationY > 100) {
                    dismissModal()
                } else {
                    self.contentViewConstraints?.update(top: initialTopOffset)
                    UIView.animate(withDuration: animationDuration) { [weak self] in
                        self?.view.superview?.layoutIfNeeded()
                    }
                }
                delegate?.didEndScroll?(offsetY: translationY)
            default:
                break
        }
    }

}

private extension ModalViewController {

    func setupConstraints() {
        let additionalBottomSpace = bottomSafeArea + contentInsets.bottom

        rootViewController.view.translatesAutoresizingMaskIntoConstraints = false
        rootViewController.view.layoutIfNeeded()

        let preferredHeight = rootViewController.clampedContentHeight + additionalBottomSpace
        let height = min(maxHeight, preferredHeight)
        let topOffset = view.frame.height - height
        self.initialTopOffset = topOffset

        if let contentViewConstraints = contentViewConstraints {
            contentViewConstraints.update(top: topOffset)
        } else {
            contentViewConstraints = .init(
                topConstraint: contentView.topAnchor --> view.topAnchor + topOffset,
                leadingConstraint: contentView.leadingAnchor --> view.leadingAnchor,
                trailingConstraint: contentView.trailingAnchor --> view.trailingAnchor,
                bottomConstraint: contentView.bottomAnchor --> view.bottomAnchor)
        }

        if let rootViewControllerContraints = rootViewControllerContraints {
            rootViewControllerContraints.update(top: contentInsets.top,
                                                height: height - contentInsets.bottom)
        } else {
            let heightConstraint = rootViewController.view.heightAnchor == (height - contentInsets.bottom)
            heightConstraint.priority = .defaultHigh
            rootViewControllerContraints = .init(
                topConstraint: rootViewController.view.topAnchor --> contentView.topAnchor + contentInsets.top,
                leadingConstraint: rootViewController.view.leadingAnchor --> contentView.leadingAnchor + contentInsets.left,
                trailingConstraint: rootViewController.view.trailingAnchor --> contentView.trailingAnchor + contentInsets.right,
                heightConstraint: heightConstraint)
        }

        dragIndicatorConstraints = .init(bottomConstraint: dragIndicator.bottomAnchor --> contentView.topAnchor + Constants.DragIndicator.spacing,
                                         heightConstraint: dragIndicator.heightAnchor == Constants.DragIndicator.height,
                                         widthConstraint: dragIndicator.widthAnchor == Constants.DragIndicator.width,
                                         centerXConstraint: dragIndicator.centerXAnchor --> contentView.centerXAnchor)
    }

}

private extension ModalViewController {

    enum Constants {

        static let cornerRadius: CGFloat = 40
        static let additionalTopSpace: CGFloat = 30
        static let dismissVelocity: CGFloat = 500

        enum DragIndicator {
            static let width: CGFloat = 35
            static let height: CGFloat = 5
            static let spacing: CGFloat = 10
        }

    }

}

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
                               contentView: UIView = defaultContentView,
                               contentInsets: UIEdgeInsets = defaultContentInsets,
                               animationDuration: TimeInterval = 0.5) -> ModalViewController {

        let modalViewController = ModalViewController()

        controller.modalViewController = modalViewController
        modalViewController.contentView = contentView
        modalViewController.contentInsets = contentInsets
        modalViewController.animationDuration = animationDuration
        modalViewController.rootViewController = controller

        let parent = parent.navigationController ?? parent

        modalViewController.beginAppearanceTransition(true, animated: true)
        modalViewController.moveAndFit(to: parent)
        
        return modalViewController
    }

    public static var defaultContentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.clipsToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner],
                                 radius: Constants.cornerRadius)
        return contentView
    }()

    public static let defaultContentInsets: UIEdgeInsets = .init(top: 20, left: 0, bottom: 20, right: 0)

    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.2)
        return view
    }()

    private lazy var dragIndicator: UIView = {
        let dragIndicator = UIView()
        dragIndicator.backgroundColor = .white
        dragIndicator.layer.cornerRadius = 4
        dragIndicator.translatesAutoresizingMaskIntoConstraints = false
        return dragIndicator
    }()

    private lazy var dismissTapGestureRecognizer: UITapGestureRecognizer = {
        UITapGestureRecognizer(target: self, action: #selector(dismissModal))
    }()

    public lazy var dragGestureRecognizer: UIPanGestureRecognizer = {
        UIPanGestureRecognizer(target: self, action: #selector(onDrag))
    }()

    private var contentView: UIView!

    private var contentInsets: UIEdgeInsets!

    private var animationDuration: TimeInterval = 0.3

    private var topConstraint: NSLayoutConstraint!

    private var heightConstraint: NSLayoutConstraint!

    private weak var rootViewController: ModalPresented!

    private var initialTopOffset: CGFloat = 0

    override public func viewDidLoad() {
        super.viewDidLoad()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        setupView()
        dimmingView.addGestureRecognizer(dismissTapGestureRecognizer)
        rootViewController.view.addGestureRecognizer(dragGestureRecognizer)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showModal(isUpdate: false)
    }

}

extension ModalViewController {

    public func update() {
        setupConstraints()
        showModal(isUpdate: true)
    }

    public func showModal(isUpdate: Bool) {
        dimmingView.layer.opacity = 0
        topConstraint == view.frame.height
        view.layoutIfNeeded()

        UIView.springAnimation(duration: animationDuration) { [weak self] in
            guard let self = self else { return }
            self.topConstraint == self.initialTopOffset
            self.dimmingView.layer.opacity = 1
            self.view.layoutIfNeeded()
        } completion: { [weak self] in
            if !isUpdate {
                self?.endAppearanceTransition()
            }
        }
    }

    @objc public func dismissModal() {
        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let self = self else { return }
            self.topConstraint == self.view.frame.height
            self.dimmingView.layer.opacity = 0
            self.view.layoutIfNeeded()
        } completion: { [weak self] tset in
            self?.rootViewController.remove()
            self?.rootViewController = nil
            self?.willMove(toParent: nil)
            self?.view.removeFromSuperview()
            self?.removeFromParent()
        }
    }

    @objc public func onDrag(sender: UIPanGestureRecognizer) {
        switch sender.state {
            case .began:
                initialTopOffset = topConstraint.constant
            case .changed:
                let translationY = sender.translation(in: view).y
                topConstraint == max(initialTopOffset + translationY, topSafeArea + Constants.additionalTopSpace)
            case .ended:
                let translationY = sender.translation(in: view).y
                let velocityY = sender.velocity(in: view).y
                if translationY > rootViewController.view.frame.height / 2
                    || velocityY > Constants.dismissVelocity {
                    dismissModal()
                } else {
                    topConstraint == initialTopOffset
                    UIView.animate(withDuration: animationDuration) { [weak self] in
                        self?.view.superview?.layoutIfNeeded()
                    }
                }
            default:
                break
        }
    }

}

private extension ModalViewController {

    func setupView() {
        view.addSubview(dimmingView)
        view.fit(dimmingView)
        view.addSubview(contentView)
        rootViewController?.move(to: self, viewPath: \.contentView)
        view.addSubview(dragIndicator)

        setupConstraints()
    }

    func setupConstraints() {
        let additionalBottomSpace = bottomSafeArea + contentInsets.bottom

        rootViewController.view.translatesAutoresizingMaskIntoConstraints = false
        rootViewController.view.layoutIfNeeded()

        let preferredHeight = rootViewController.contentHeight + additionalBottomSpace
        let height = min(view.frame.height - topSafeArea - Constants.additionalTopSpace, preferredHeight)
        let topOffset = view.frame.height - height
        self.initialTopOffset = topOffset

        if let topConstraint = self.topConstraint {
            topConstraint.constant = topOffset
        } else {
            topConstraint = contentView.topAnchor => view.topAnchor + topOffset
        }

        if let heightConstraint = heightConstraint {
            heightConstraint.constant = height - contentInsets.bottom
        } else {
            heightConstraint = rootViewController.view.heightAnchor == (height - contentInsets.bottom)
            heightConstraint.priority = .defaultHigh
        }

        NSLayoutConstraint.activate([
            topConstraint,
            contentView.leadingAnchor => view.leadingAnchor,
            contentView.trailingAnchor => view.trailingAnchor,
            contentView.bottomAnchor => view.bottomAnchor,
            rootViewController.view.topAnchor => contentView.topAnchor + contentInsets.top,
            rootViewController.view.leadingAnchor => contentView.leadingAnchor + contentInsets.left,
            rootViewController.view.trailingAnchor => contentView.trailingAnchor + contentInsets.right,
            heightConstraint
        ])

        NSLayoutConstraint.activate([
            dragIndicator.bottomAnchor => contentView.topAnchor + Constants.DragIndicator.spacing,
            dragIndicator.centerXAnchor => contentView.centerXAnchor,
            dragIndicator.widthAnchor == Constants.DragIndicator.width,
            dragIndicator.heightAnchor == Constants.DragIndicator.height
        ])
    }

}

private extension ModalViewController {

    enum Constants {

        static let cornerRadius: CGFloat = 30
        static let additionalTopSpace: CGFloat = 30
        static let dismissVelocity: CGFloat = 500

        enum DragIndicator {
            static let width: CGFloat = 50
            static let height: CGFloat = 7
            static let spacing: CGFloat = -5
        }

    }

}


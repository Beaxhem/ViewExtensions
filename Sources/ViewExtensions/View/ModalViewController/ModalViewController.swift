//
//  ModalViewController.swift
//  
//
//  Created by Ilya Senchukov on 26.09.2021.
//

import UIKit
import RxSwift
import RxCocoa

public class ModalViewController: UIViewController {

    public static func present(in parent: UIViewController,
                               controller: ModalPresented,
                               contentView: UIView = defaultContentView,
                               contentInsets: UIEdgeInsets = defaultContentInsets,
                               animationDuration: TimeInterval = 0.5) -> ModalViewController {

        let modalViewController = ModalViewController()

        controller.dragGestureRecognizer = modalViewController.dragGestureRecognizer
        modalViewController.contentView = contentView
        modalViewController.contentInsets = contentInsets
        modalViewController.animationDuration = animationDuration
        modalViewController.rootViewController = controller
        modalViewController.moveAndFit(to: parent)

        return modalViewController
    }

    public static var defaultContentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.clipsToBounds = true
        contentView.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner],
                                 radius: Constants.cornerRadius)
        return contentView
    }()

    public static let defaultContentInsets: UIEdgeInsets = .init(top: 20, left: 0, bottom: 0, right: 0)

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

    private lazy var dragGestureRecognizer: UIPanGestureRecognizer = {
        UIPanGestureRecognizer(target: self, action: #selector(onDrag))
    }()

    private var contentView: UIView!

    private var contentInsets: UIEdgeInsets!

    private var animationDuration: TimeInterval = 0.3

    private var topConstraint: NSLayoutConstraint!

    private var rootViewController: UIViewController!

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
        showModal()
    }

}

extension ModalViewController {

    public func showModal() {
        navigationController?.navigationBar.toggle()
        dimmingView.layer.opacity = 0
        topConstraint <= view.frame.height
        view.layoutIfNeeded()

        UIView.springAnimation(duration: animationDuration) { [weak self] in
            guard let self = self else { return }
            self.topConstraint <= self.initialTopOffset
            self.dimmingView.layer.opacity = 1
            self.view.layoutIfNeeded()
        }
    }

    @objc public func dismissModal() {
        navigationController?.navigationBar.toggle()
        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let self = self else { return }
            self.topConstraint <= self.view.frame.height
            self.dimmingView.layer.opacity = 0
            self.view.layoutIfNeeded()
        } completion: { [weak self] tset in
            self?.rootViewController.remove()
            self?.view.removeFromSuperview()
            self?.rootViewController = nil
        }
    }

    @objc public func onDrag(sender: UIPanGestureRecognizer) {
        switch sender.state {
            case .began:
                initialTopOffset = topConstraint.constant
            case .changed:
                let translationY = sender.translation(in: view).y
                topConstraint <= max(initialTopOffset + translationY, topSafeArea + Constants.additionalTopSpace)
            case .ended:
                let translationY = sender.translation(in: view).y
                let velocityY = sender.velocity(in: view).y
                if translationY > rootViewController.view.frame.height / 2
                    || velocityY > Constants.dismissVelocity {
                    dismissModal()
                } else {
                    topConstraint <= initialTopOffset
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

        var preferredHeight: CGFloat
        switch rootViewController {
            case is ModalPresentedCollectionViewController:
                guard let rootViewController = rootViewController as? ModalPresentedCollectionViewController else {
                    return
                }

                rootViewController._collectionView.layoutSubviews()
                let contentSizeHeight = rootViewController._collectionView.collectionViewLayout.collectionViewContentSize.height

                rootViewController.view.forceLayout()
                let containerHeight = rootViewController.view.frame.height

                preferredHeight = containerHeight + contentSizeHeight + additionalBottomSpace
            default:
                preferredHeight = rootViewController.view.systemLayoutSizeFitting(
                    view.frame.size,
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .fittingSizeLevel
                ).height + additionalBottomSpace
        }   

        let height = min(view.frame.height - topSafeArea - Constants.additionalTopSpace, preferredHeight)

        let topOffset = view.frame.height - height
        let topConstraint = contentView.topAnchor => view.topAnchor + topOffset

        self.initialTopOffset = topOffset
        self.topConstraint = topConstraint

        NSLayoutConstraint.activate([
            topConstraint,
            contentView.leadingAnchor => view.leadingAnchor,
            contentView.trailingAnchor => view.trailingAnchor,
            contentView.bottomAnchor => view.bottomAnchor,
            rootViewController.view.topAnchor => contentView.topAnchor + contentInsets.top,
            rootViewController.view.leadingAnchor => contentView.leadingAnchor + contentInsets.left,
            rootViewController.view.trailingAnchor => contentView.trailingAnchor + contentInsets.right,
            rootViewController.view.heightAnchor ==> (height - contentInsets.bottom)
        ])

        NSLayoutConstraint.activate([
            dragIndicator.bottomAnchor => contentView.topAnchor + Constants.DragIndicator.spacing,
            dragIndicator.centerXAnchor => contentView.centerXAnchor,
            dragIndicator.widthAnchor ==> Constants.DragIndicator.width,
            dragIndicator.heightAnchor ==> Constants.DragIndicator.height
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

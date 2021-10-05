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
                               animationDuration: TimeInterval = 0.5) -> ModalViewController {
        let modalViewController = ModalViewController()

        controller.dragGestureRecognizer = modalViewController.dragGestureRecognizer
        modalViewController.contentView = contentView
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

    private lazy var propertyAnimator: UIViewPropertyAnimator = {
        UIViewPropertyAnimator(duration: 0.3, curve: .easeOut)
    }()

    private var contentView: UIView!

    private var animationDuration: TimeInterval = 0.3

    private var yConstraint: NSLayoutConstraint!

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

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupRootView()
    }

}

extension ModalViewController {

    public func showModal() {
        navigationController?.navigationBar.toggle()
        dimmingView.layer.opacity = 0
        yConstraint?.constant = view.frame.height
        view.layoutIfNeeded()

        UIView.springAnimation(duration: animationDuration) { [weak self] in
            guard let self = self else { return }
            self.yConstraint.constant = self.initialTopOffset
            self.dimmingView.layer.opacity = 1
            self.view.layoutIfNeeded()
        }
    }

    @objc public func dismissModal() {
        navigationController?.navigationBar.toggle()
        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let self = self else { return }
            self.yConstraint.constant = self.view.frame.height
            self.dimmingView.layer.opacity = 0
            self.view.layoutIfNeeded()
        } completion: { [weak self] tset in
            self?.rootViewController.view.removeFromSuperview()
            self?.view.removeFromSuperview()
            self?.rootViewController.removeFromParent()
        }
    }

    @objc public func onDrag(sender: UIPanGestureRecognizer) {
        switch sender.state {
            case .began:
                initialTopOffset = yConstraint.constant
            case .changed:
                let translationY = sender.translation(in: view).y
                yConstraint.constant = max(initialTopOffset + translationY, topSafeArea + Constants.additionalTopSpace)
            case .ended:
                let translationY = sender.translation(in: view).y
                let velocityY = sender.velocity(in: view).y
                if translationY > rootViewController.view.frame.height / 2
                    || velocityY > Constants.dismissVelocity {
                    dismissModal()
                } else {
                    yConstraint.constant = initialTopOffset
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

                preferredHeight = containerHeight + contentSizeHeight + bottomSafeArea
            default:
                preferredHeight = rootViewController.view.systemLayoutSizeFitting(
                    view.frame.size,
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .fittingSizeLevel
                ).height + bottomSafeArea
        }   

        let height = min(view.frame.height - topSafeArea - Constants.additionalTopSpace, preferredHeight)

        let topOffset = view.frame.height - height
        let topConstraint = contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: topOffset)

        initialTopOffset = topOffset
        yConstraint = topConstraint

        NSLayoutConstraint.activate([
            topConstraint,
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rootViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            rootViewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rootViewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rootViewController.view.heightAnchor.constraint(equalToConstant: height)
        ])

        NSLayoutConstraint.activate([
            dragIndicator.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: -5),
            dragIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dragIndicator.widthAnchor.constraint(equalToConstant: 50),
            dragIndicator.heightAnchor.constraint(equalToConstant: 7)
        ])
    }

    func setupRootView() {
    }

}

private extension ModalViewController {

    enum Constants {
        static let cornerRadius: CGFloat = 30
        static let additionalTopSpace: CGFloat = 30
        static let dismissVelocity: CGFloat = 500
    }

}

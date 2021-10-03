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
                               controller: UIViewController,
                               animationDuration: TimeInterval = 0.5) -> ModalViewController {
        let modalViewController = ModalViewController()

        modalViewController.animationDuration = animationDuration
        modalViewController.rootViewController = controller
        modalViewController.moveAndFit(to: parent)

        return modalViewController
    }

    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.2)
        return view
    }()

    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.clipsToBounds = true
        return contentView
    }()

    private lazy var dismissTapGestureRecognizer: UITapGestureRecognizer = {
        UITapGestureRecognizer(target: self, action: #selector(dismissModal))
    }()

    private lazy var dragGestureRecognizer: UIPanGestureRecognizer = {
        UIPanGestureRecognizer(target: self, action: #selector(onDrag))
    }()

    private var animationDuration: TimeInterval = 0.3

    private var yConstraint: NSLayoutConstraint!

    private var rootViewController: UIViewController!

    private var initialTopOffset: CGFloat = 0

    override public func viewDidLoad() {
        super.viewDidLoad()
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
        dimmingView.layer.opacity = 0
        yConstraint?.constant = view.frame.height
        view.layoutIfNeeded()

        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let self = self else { return }
            self.yConstraint.constant = self.initialTopOffset
            self.dimmingView.layer.opacity = 1
            self.view.layoutIfNeeded()
        }
    }

    @objc public func dismissModal() {
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut]) { [weak self] in
            guard let self = self else { return }
            self.yConstraint.constant = self.view.frame.height
            self.dimmingView.layer.opacity = 0
            self.view.layoutIfNeeded()
        } completion: { [weak self] tset in
            self?.view.removeFromSuperview()
        }
    }

    @objc public func onDrag(sender: UIPanGestureRecognizer) {
        switch sender.state {
            case .began:
                initialTopOffset = yConstraint.constant
            case .changed:
                let translationY = sender.translation(in: view).y
                let bottomSafeArea = UIApplication.shared.windows.first!.safeAreaInsets.bottom

                yConstraint.constant = max(initialTopOffset + translationY,
                                           bottomSafeArea + Constants.additionalTopSpace)
            case .ended:
                let translationY = sender.translation(in: view).y
                let velocityY = sender.velocity(in: view).y
                if translationY > rootViewController.view.frame.height / 2
                   || velocityY > 500 {

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

        setupConstraints()
    }

    func setupConstraints() {
        let preferredHeight = rootViewController.view.systemLayoutSizeFitting(view.frame.size, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        let bottomSafeArea = UIApplication.shared.windows.first!.safeAreaInsets.bottom
        let height = preferredHeight + bottomSafeArea

        let topOffset = max(view.frame.height - height,
                            bottomSafeArea + Constants.additionalTopSpace)
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
    }

    func setupRootView() {
        contentView.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner],
                                 radius: Constants.cornerRadius)
    }

}

private extension ModalViewController {

    enum Constants {
        static let cornerRadius: CGFloat = 30
        static let additionalTopSpace: CGFloat = 30
    }

}

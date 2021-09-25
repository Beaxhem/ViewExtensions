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

    public static func present(in parent: UIViewController, controller: UIViewController) -> ModalViewController {
        let modalViewController = ModalViewController()
        modalViewController.rootViewController = controller

        UIView.transition(with: parent.view, duration: 0.1, options: [.transitionCrossDissolve], animations: {
            modalViewController.moveAndFit(to: parent)
        }, completion: nil)

        return modalViewController
    }

    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.2)

        return view
    }()

    private var yConstraint: NSLayoutConstraint?

    private var rootViewController: UIViewController?

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        navigationController?.navigationBar.toggle()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        dimmingView.addGestureRecognizer(tapGestureRecognizer)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupRootView()
    }

    @objc public func dismissModal() {
        guard let parent = parent else { return }

        navigationController?.navigationBar.toggle()

        UIView.transition(with: parent.view, duration: 0.2, options: [.transitionCrossDissolve]) { [weak self] in
            self?.view.removeFromSuperview()
        }
    }
}

private extension ModalViewController {

    func setupView() {
        view.addSubview(dimmingView)
        view.fit(dimmingView)
        rootViewController?.move(to: self)

        setupConstraints()
    }

    func setupConstraints() {
        guard let rootViewController = rootViewController else { return }

        let preferredHeight = rootViewController.view.systemLayoutSizeFitting(view.frame.size, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        let bottomSafeArea = UIApplication.shared.windows.first!.safeAreaInsets.bottom

        let topOffset = max(view.frame.height - bottomSafeArea - preferredHeight, bottomSafeArea + 10)
        let topConstraint = rootViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: topOffset)
        topConstraint.priority = .defaultHigh
        yConstraint = topConstraint

        NSLayoutConstraint.activate([
            topConstraint,
            rootViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func setupRootView() {
        rootViewController?.view.roundCorners(corners: [.topLeft, .topRight], radius: 30)
    }

}

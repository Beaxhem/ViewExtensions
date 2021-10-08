//
//  PopoverView.swift
//  
//
//  Created by Ilya Senchukov on 06.10.2021.
//

import UIKit
import SwiftUI

public protocol PopoverDisplayingViewController: UIViewController {

    var popover: PopoverView? { get set }

}

extension PopoverDisplayingViewController {

    func deinitPopover() {
        popover = nil
    }

}

public class PopoverView: UIView {

    public static func defaultContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .orange
        container.layer.cornerRadius = 10
        return container
    }

    public static func show(text: String,
                            in parent: PopoverDisplayingViewController,
                            targetView: UIView,
                            swooshDirection: SwooshView.Direction = .left,
                            container: UIView = defaultContainer(),
                            maxWidth: CGFloat = 200) -> PopoverView {
        let popover = PopoverView(parent: parent,
                                  targetView: targetView,
                                  swooshDirection: swooshDirection,
                                  container: container,
                                  maxWidth: maxWidth)
        popover.text = text
        return popover
    }

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var swoosh: SwooshView = {
        let swoosh = SwooshView(color: container.backgroundColor ?? .white, direction: swooshDirection)
        swoosh.translatesAutoresizingMaskIntoConstraints = false
        swoosh.backgroundColor = .clear
        return swoosh
    }()

    private weak var parent: PopoverDisplayingViewController!

    private weak var targetView: UIView!

    private let container: UIView

    private let swooshDirection: SwooshView.Direction

    private let maxWidth: CGFloat

    public var text: String? {
        didSet {
            label.text = text
        }
    }

    public init(parent: PopoverDisplayingViewController, targetView: UIView, swooshDirection: SwooshView.Direction, container: UIView, maxWidth: CGFloat) {
        self.parent = parent
        self.swooshDirection = swooshDirection
        self.targetView = targetView
        self.container = container
        self.maxWidth = maxWidth

        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension PopoverView {

    @objc public func hide() {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.layer.opacity = 0
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.removeFromSuperview()
            self.parent.deinitPopover()
        }
    }

}

private extension PopoverView {

    func commonInit() {
        parent.view.subviews
            .filter { $0 is PopoverView }
            .forEach { subview in
                subview.removeFromSuperview()
            }

        setupView()
        setupConstraints()
        showWithAnimation()
    }

    func showWithAnimation() {
        transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.springAnimation(duration: Constants.animationDuration) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }

    func setupView() {
        isUserInteractionEnabled = true
        targetView.isUserInteractionEnabled = true
        container.isUserInteractionEnabled = true

        translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false

        addGestureRecognizer(dismissTapRecognizer)
        targetView.addGestureRecognizer(dismissTapRecognizer)

        addSubview(swoosh)
        container.addSubview(label)
        container.fit(label, constant: 8)

        addSubview(container)
        parent.view.addSubview(self)
    }

    func setupConstraints() {
        var constraints = [NSLayoutConstraint]()

        switch swooshDirection {
            case .down, .up:
                constraints.append(swoosh.centerXAnchor => targetView.centerXAnchor)
                constraints.append(centerXAnchor => targetView.centerXAnchor)
            case .left, .right:
                constraints.append(swoosh.centerYAnchor => targetView.centerYAnchor)
                constraints.append(centerYAnchor => targetView.centerYAnchor)
        }

        switch swooshDirection {
            case .up:
                constraints.append(topAnchor => targetView.bottomAnchor + Constants.targetDistance)
            case .right:
                constraints.append(swoosh.trailingAnchor => container.trailingAnchor + 8)
                constraints.append(trailingAnchor => targetView.leadingAnchor - Constants.targetDistance)
            case .down:
                constraints.append(swoosh.bottomAnchor => container.bottomAnchor)
                constraints.append(bottomAnchor => targetView.topAnchor - Constants.targetDistance)
            case .left:
                constraints.append(swoosh.leadingAnchor => container.leadingAnchor - 8)
                constraints.append(leadingAnchor => targetView.trailingAnchor + Constants.targetDistance)
        }

        NSLayoutConstraint.activate(constraints)
        NSLayoutConstraint.activate([
            container.leadingAnchor => leadingAnchor,
            container.topAnchor => topAnchor,
            container.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth),
            trailingAnchor => container.trailingAnchor,
            bottomAnchor => container.bottomAnchor,
            swoosh.heightAnchor ==> (Constants.swooshWidth / 1.5),
            swoosh.widthAnchor ==> Constants.swooshWidth
        ])
    }

    var dismissTapRecognizer: UITapGestureRecognizer {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(hide))
        recognizer.delegate = self
        return recognizer
    }

}

extension PopoverView: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

}

private extension PopoverView {

    enum Constants {
        static let targetDistance: CGFloat = 20
        static let animationDuration: TimeInterval = 0.3
        static let swooshWidth: CGFloat = 30
    }
}

//
//  PopoverView.swift
//  
//
//  Created by Ilya Senchukov on 06.10.2021.
//

import UIKit
import SwiftUI

public class PopoverView: UIView {

    public static func defaultContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .orange
        container.layer.cornerRadius = 10
        return container
    }

    public static func show(text: String, in parent: UIView, targetView: UIView, swooshDirection: SwooshView.Direction = .left, container: UIView = defaultContainer()) -> PopoverView {
        let popover = PopoverView(parent: parent,
                                  targetView: targetView,
                                  swooshDirection: swooshDirection,
                                  container: container)
        popover.text = text
        return popover
    }

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()

    private lazy var swoosh: SwooshView = {
        let swoosh = SwooshView(color: container.backgroundColor ?? .white, direction: swooshDirection)
        swoosh.translatesAutoresizingMaskIntoConstraints = false
        swoosh.backgroundColor = .clear
        return swoosh
    }()

    private weak var parent: UIView!

    private weak var targetView: UIView!

    private let container: UIView

    private var swooshDirection: SwooshView.Direction

    public var text: String? {
        didSet {
            label.text = text
        }
    }

    public init(parent: UIView, targetView: UIView, swooshDirection: SwooshView.Direction, container: UIView) {
        self.parent = parent
        self.swooshDirection = swooshDirection
        self.targetView = targetView
        self.container = container

        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("deinit")
    }

}

extension PopoverView {

    @objc public func hide() {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.layer.opacity = 0
        } completion: { [weak self] _ in
            print("hide")
            self?.container.removeFromSuperview()
            self?.swoosh.removeFromSuperview()
            self?.targetView = nil
            self?.parent = nil
            self?.removeFromSuperview()
        }
    }

}

private extension PopoverView {

    func commonInit() {
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
        parent.addSubview(self)
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
            trailingAnchor => container.trailingAnchor,
            bottomAnchor => container.bottomAnchor,
            swoosh.heightAnchor ==> (Constants.swooshWidth / 1.5),
            swoosh.widthAnchor ==> Constants.swooshWidth
        ])
    }

    var dismissTapRecognizer: UITapGestureRecognizer {
        UITapGestureRecognizer(target: self, action: #selector(hide))
    }

}

private extension PopoverView {

    enum Constants {
        static let targetDistance: CGFloat = 20
        static let animationDuration: TimeInterval = 0.3
        static let swooshWidth: CGFloat = 30
    }
}

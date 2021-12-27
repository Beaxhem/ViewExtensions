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

        let parent = parent.navigationController ?? parent

        modalViewController.beginAppearanceTransition(true, animated: true)
        modalViewController.moveAndFit(to: parent)
        
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

    private static let defaultContentInsets: UIEdgeInsets = .init(top: 20, left: 0, bottom: 20, right: 0)

    public lazy var maxHeight: CGFloat = {
        view.frame.height - topSafeArea
    }()

    public var isAnimating: Bool = false

    private lazy var dragIndicator: UIView = {
        let dragIndicator = UIView()
        dragIndicator.backgroundColor = .lightGray
        dragIndicator.layer.cornerRadius = 2.5
        dragIndicator.translatesAutoresizingMaskIntoConstraints = false
        return dragIndicator
    }()

    private lazy var dismissTapGestureRecognizer: UITapGestureRecognizer = {
        UITapGestureRecognizer(target: self, action: #selector(dismissModal))
    }()

    public lazy var dragGestureRecognizer: UIPanGestureRecognizer = {
        UIPanGestureRecognizer(target: self, action: #selector(onDrag))
    }()

    public weak var rootViewController: ModalPresented!
    
    public weak var delegate: ModalViewDelegate?

    private var dimmingView: UIView!

    private var contentView: UIView!

    private var contentInsets: UIEdgeInsets!

    private var animationDuration: TimeInterval!

    private var heightConstraint: NSLayoutConstraint!

    private var initialTopOffset: CGFloat = 0

    var topConstraint: NSLayoutConstraint!

    public var topOffset: CGFloat {
        topConstraint.constant
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
        dimmingView.addGestureRecognizer(dismissTapGestureRecognizer)
        rootViewController.view.addGestureRecognizer(dragGestureRecognizer)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissModal()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showModal(isUpdate: false)
    }

}

extension ModalViewController {

    public func update() {
        setupConstraints()
        if isAnimating {
            showModal(isUpdate: true)
        } else {
            UIView.animate(withDuration: animationDuration) {
                self.topConstraint == self.initialTopOffset
                self.view.layoutIfNeeded()
            }
        }

    }

    public func showModal(isUpdate: Bool) {
        dimmingView.layer.opacity = 0
        topConstraint == view.frame.height
        view.layoutIfNeeded()
        isAnimating = true
        UIView.springAnimation(duration: animationDuration) { [weak self] in
            guard let self = self else { return }
            self.topConstraint == self.initialTopOffset
            self.dimmingView.layer.opacity = 1
            self.view.layoutIfNeeded()
        } completion: { [weak self] in
            self?.isAnimating = false
            if !isUpdate {
                self?.endAppearanceTransition()
            }
        }
    }

    @objc public func dismissModal() {
        isAnimating = true
        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let self = self else { return }
            self.topConstraint == self.view.frame.height
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

    @objc public func onDrag(sender: UIPanGestureRecognizer) {
        switch sender.state {
            case .began:
                initialTopOffset = topConstraint.constant
            case .changed:
                let translationY = sender.translation(in: view).y / 2
                let newOffset = initialTopOffset + translationY
                topConstraint == max(newOffset, topSafeArea)
                delegate?.didScroll?(offsetY: translationY)
            case .ended:
                let translationY = sender.translation(in: view).y
                let velocityY = sender.velocity(in: view).y
                if translationY > rootViewController.view.frame.height / 2
                    || (velocityY > Constants.dismissVelocity && translationY > 100) {
                    dismissModal()
                } else {
                    topConstraint == initialTopOffset
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

        let preferredHeight = rootViewController.clampedContentHeight + additionalBottomSpace
        let height = min(maxHeight, preferredHeight)
        let topOffset = view.frame.height - height
        self.initialTopOffset = topOffset

        if let topConstraint = self.topConstraint {
            topConstraint.constant = topOffset
        } else {
            topConstraint = contentView.topAnchor --> view.topAnchor + topOffset
        }

        if var heightConstraint = heightConstraint {
            heightConstraint == height - contentInsets.bottom
        } else {
            heightConstraint = rootViewController.view.heightAnchor == (height - contentInsets.bottom)
            heightConstraint.priority = .defaultHigh
        }

        NSLayoutConstraint.activate([
            topConstraint,
            contentView.leadingAnchor --> view.leadingAnchor,
            contentView.trailingAnchor --> view.trailingAnchor,
            contentView.bottomAnchor --> view.bottomAnchor,
            rootViewController.view.topAnchor --> contentView.topAnchor + contentInsets.top,
            rootViewController.view.leadingAnchor --> contentView.leadingAnchor + contentInsets.left,
            rootViewController.view.trailingAnchor --> contentView.trailingAnchor + contentInsets.right,
            heightConstraint
        ])

        NSLayoutConstraint.activate([
            dragIndicator.bottomAnchor --> contentView.topAnchor + Constants.DragIndicator.spacing,
            dragIndicator.centerXAnchor --> contentView.centerXAnchor,
            dragIndicator.widthAnchor == Constants.DragIndicator.width,
            dragIndicator.heightAnchor == Constants.DragIndicator.height
        ])
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

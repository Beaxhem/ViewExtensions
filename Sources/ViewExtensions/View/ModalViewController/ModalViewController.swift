//
//  ModalViewController.swift
//  
//
//  Created by Ilya Senchukov on 26.09.2021.
//

import UIKit

public class ModalViewController: UIViewController {

    @discardableResult
    public static func present(in parent: UIViewController,
                               controller: ModalPresented,
                               contentInsets: UIEdgeInsets? = nil,
                               animationDuration: TimeInterval = 0.4,
                               completion: (() -> Void)? = nil) -> ModalViewController {

        let modalViewController = ModalViewController()

        controller.modalViewController = modalViewController
        modalViewController.dimmingView = controller.dimmingView ?? Constants.defaultDimmingView
		modalViewController.contentView = setupContentView(presentedController: controller)
        modalViewController.contentInsets = contentInsets ?? Constants.defaultContentInsets
        modalViewController.animationDuration = animationDuration
        modalViewController.rootViewController = controller
        modalViewController.completion = completion
		modalViewController.parentVC = parent
		let parent = parent.navigationController ?? parent
		modalViewController.moveAndFit(to: parent)
		modalViewController.beginAppearanceTransition(true, animated: true)
        return modalViewController
    }

    public lazy var maxHeight: CGFloat = view.frame.height - topSafeArea

    private lazy var dragIndicator: UIView = {
        let dragIndicator = UIView()
        dragIndicator.cornerRadius = 2.5
        dragIndicator.translatesAutoresizingMaskIntoConstraints = false
        return dragIndicator
    }()

	public weak var parentVC: UIViewController?

	public override var childForStatusBarStyle: UIViewController? {
		rootViewController
	}

	public override var preferredStatusBarStyle: UIStatusBarStyle {
		rootViewController?.preferredStatusBarStyle ?? parentVC?.preferredStatusBarStyle ?? .default
	}

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

    public var completion: (() -> Void)?

	public var isAnimating = false

	public var isDismissing: Bool = false

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
		setupView()
		setupConstraints()
		setupGestureRecognizers()
    }

	public override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.interactivePopGestureRecognizer?.isEnabled = false
		showModal()
	}

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        dismissModal(animated: animated)
    }

}

public extension ModalViewController {

    func updateWithSpring(duration: TimeInterval = 0.2, animated: Bool = true) {
        if animated {
            UIView.springAnimation(duration: duration) { [weak self] in
                self?.setupConstraints()
                self?.view.layoutIfNeeded()
            }
        } else {
            setupConstraints()
        }
    }

    func update(duration: TimeInterval = 0.2, animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: duration) { [weak self] in
                self?.setupConstraints()
                self?.view.layoutIfNeeded()
            }
        } else {
            setupConstraints()
        }
    }

	func setViewController(_ vc: ModalPresented!) {
		rootViewController?.remove()
		rootViewControllerContraints = nil
		rootViewController = vc
		vc.modalViewController = self
		setupView()
		setupGestureRecognizers()
		updateWithSpring()
	}

	@objc func dismissModal(progress: Double = 0, animated: Bool = true, completion: (() -> Void)? = nil) {
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        func dismiss() {
            self.completion?()
            isAnimating = true
			isDismissing = true
            rootViewController?.beginAppearanceTransition(false, animated: true)
			let animationDuration = animationDuration * (1 - progress)
            UIView.animate(withDuration: animationDuration) { [weak self] in
                guard let self = self else { return }
                self.contentViewConstraints?.update(top: self.view.frame.height)
                self.dimmingView.layer.opacity = 0
				self.view.layoutSubviews()
            } completion: { [weak self] _ in
                completion?()
				let parent = self?.parentVC
                self?.isAnimating = false
                self?.rootViewController?.remove()
                self?.rootViewController = nil
				self?.remove()
				UIView.animate(withDuration: 0.1) { [weak parent] in
					parent?.setNeedsStatusBarAppearanceUpdate()
				}
				self?.didMove(toParent: nil)
            }
        }   
        if animated {
            dismiss()
        } else {
            UIView.performWithoutAnimation {
                dismiss()
            }
        }
    }

}

private extension ModalViewController {

	func setupView() {
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.layer.masksToBounds = true
		if !view.subviews.contains(where: { $0 == dimmingView }) {
			view.addSubview(dimmingView)
			view.fit(dimmingView)
			view.addSubview(contentView)
			view.addSubview(dragIndicator)
		}
		rootViewController?.move(to: self, viewPath: \.contentView)
		view.insetsLayoutMarginsFromSafeArea = false
	}

	static func setupContentView(presentedController: ModalPresented) -> UIView {
		let view = UIView()
		presentedController.setupContentView(view)
		return view
	}

	func setupGestureRecognizers() {
		let dismissTapGestureRecognizer = UITapGestureRecognizer(target: self,
																 action: #selector(tapOutsideModal))
		dimmingView.addGestureRecognizer(dismissTapGestureRecognizer)
		rootViewController.view.addGestureRecognizer(dragGestureRecognizer)
	}

}

private extension ModalViewController {

	func showModal() {
		dimmingView.layer.opacity = 0
		contentViewConstraints?.update(top: view.frame.height)
		view.layoutIfNeeded()
		isAnimating = true
		UIView.animate(withDuration: 0.1) { [weak self] in
			self?.parentVC?.setNeedsStatusBarAppearanceUpdate()
		}
		UIView.springAnimation(duration: animationDuration, options: [.curveEaseIn]) { [weak self] in
			guard let self = self else { return }
			self.contentViewConstraints?.update(top: self.initialTopOffset)
			self.dimmingView.layer.opacity = 1
			self.view.layoutSubviews()
		} completion: { [weak self] in
			self?.isAnimating = false
			self?.endAppearanceTransition()
		}
	}

	@objc func tapOutsideModal() {
		dismissModal(animated: true)
	}

	@objc func onDrag(sender: UIPanGestureRecognizer) {
		switch sender.state {
			case .began:
				initialTopOffset = contentViewConstraints!.topConstraint!.constant
			case .changed:
				let translationY = sender.translation(in: view).y
				let newOffset = initialTopOffset + translationY
				UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseIn]) { [weak self] in
					guard let topSafeArea = self?.topSafeArea else { return }
					self?.contentViewConstraints?.update(top: max(newOffset, topSafeArea))
				}
				delegate?.didScroll?(offsetY: translationY)
			case .ended:
				let translationY = sender.translation(in: view).y
				let velocityY = sender.velocity(in: view).y
				if translationY > rootViewController.view.frame.height / 2
					|| (velocityY > Constants.dismissVelocity && translationY > 100) {
					dismissModal(progress: initialTopOffset / translationY)
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

		static let defaultContentInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

		static var defaultContentView: UIView = {
			let contentView = UIView()
			contentView.backgroundColor = .systemBackground
			contentView.clipsToBounds = true
			contentView.translatesAutoresizingMaskIntoConstraints = false
			contentView.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner],
									 radius: Constants.cornerRadius)
			return contentView
		}()

		static var defaultDimmingView: UIView = {
			let view = UIView()
			view.backgroundColor = .black.withAlphaComponent(0.2)
			return view
		}()

    }

}

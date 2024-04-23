//
//  KeyboardHandler.swift
//  
//
//  Created by Ilya Senchukov on 09.01.2022.
//

import UIKit

public struct KeyboardInfo: Equatable {

    public let animationDuration: Double

    public let animationCurve: UIView.AnimationCurve

    public let frameBegin: CGRect

    public let frameEnd: CGRect

    public let isLocal: Bool

    public init?(_ notification: Notification) {
        guard let userInfo: NSDictionary = notification.userInfo as NSDictionary?,
              let keyboardAnimationCurve = (userInfo.object(forKey: UIResponder.keyboardAnimationCurveUserInfoKey) as? NSValue) as? Int,
              let keyboardAnimationDuration = (userInfo.object(forKey: UIResponder.keyboardAnimationDurationUserInfoKey) as? NSValue) as? Double,
              let keyboardIsLocal = (userInfo.object(forKey: UIResponder.keyboardIsLocalUserInfoKey) as? NSValue) as? Bool,
              let keyboardFrameBegin = (userInfo.object(forKey: UIResponder.keyboardFrameBeginUserInfoKey) as? NSValue)?.cgRectValue,
              let keyboardFrameEnd = (userInfo.object(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue)?.cgRectValue else {
                  return nil
              }

        self.animationDuration = keyboardAnimationDuration
        var animationCurve = UIView.AnimationCurve.easeInOut
        NSNumber(value: keyboardAnimationCurve).getValue(&animationCurve)
        self.animationCurve = animationCurve
        self.isLocal = keyboardIsLocal
        self.frameBegin = keyboardFrameBegin
        self.frameEnd = keyboardFrameEnd
    }

}

@MainActor
public protocol KeyboardHandlerDelegate: AnyObject {
    func keyboardWillAppear(_ info: KeyboardInfo)
    func keyboardWillDisappear(_ info: KeyboardInfo)
    func keyboardWillChangeFrame(_ info: KeyboardInfo)
    func keyboardDidChangeFrame(_ info: KeyboardInfo)
}

public extension KeyboardHandlerDelegate {
    func keyboardWillAppear(_ info: KeyboardInfo) { }
    func keyboardWillDisappear(_ info: KeyboardInfo) { }
    func keyboardWillChangeFrame(_ info: KeyboardInfo) { }
    func keyboardDidChangeFrame(_ info: KeyboardInfo) { }
}

@MainActor
public class KeyboardHandler {

    public typealias Handler = (KeyboardInfo) -> Void

    public var isKeyboardShown: Bool = false

    private weak var delegate: KeyboardHandlerDelegate?

    public init(delegate: KeyboardHandlerDelegate) {
        self.delegate = delegate
        subscribe()
    }

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

}

private extension KeyboardHandler {

    @objc func keyboardWillShowSubscription(_ notification: Notification) {
        guard !self.isKeyboardShown,
              let info = KeyboardInfo(notification)
        else { return }

        isKeyboardShown = true
        delegate?.keyboardWillAppear(info)
    }

    @objc func keyboardWillHideSubscription(_ notification: Notification) {
        guard self.isKeyboardShown,
              let info = KeyboardInfo(notification)
        else { return }

        isKeyboardShown = false
        delegate?.keyboardWillDisappear(info)

    }

    @objc func keyboardWillChangeSubscription(_ notification: Notification) {
        guard let info = KeyboardInfo(notification) else { return }
        delegate?.keyboardWillChangeFrame(info)
    }

    @objc func keyboardDidChangeSubscription(_ notification: Notification) {
        guard let info = KeyboardInfo(notification) else { return }
        delegate?.keyboardDidChangeFrame(info)
    }

    func subscribe() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShowSubscription(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHideSubscription(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeSubscription(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
}

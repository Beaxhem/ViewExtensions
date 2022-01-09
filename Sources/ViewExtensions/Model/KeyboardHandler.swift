//
//  KeyboardHandler.swift
//  
//
//  Created by Ilya Senchukov on 09.01.2022.
//

import UIKit

public class KeyboardHandler {

    public typealias Handler = (CGRect) -> Void

    public var isKeyboardShown: Bool = false

    public init(willShow: @escaping Handler, willHide: @escaping Handler) {
        keyboardWillHideSubscription(handler: willHide)
        keyboardWillShowSubscription(handler: willShow)
    }

}

private extension KeyboardHandler {

    func keyboardWillShowSubscription(handler: @escaping Handler) {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] notification in
            guard let self = self,
                  !self.isKeyboardShown,
                  let keyboardFrame = Self.keyboardFrame(from: notification)
            else { return }

            self.isKeyboardShown = true
            handler(keyboardFrame)
        }
    }

    func keyboardWillHideSubscription(handler: @escaping Handler) {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: .main) { [weak self] notification in
            guard let self = self,
                  self.isKeyboardShown,
                  let keyboardFrame = Self.keyboardFrame(from: notification)
            else { return }

            self.isKeyboardShown = false
            handler(keyboardFrame)
        }
    }

    static func keyboardFrame(from notification: Notification) -> CGRect? {
        guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return nil }

        return keyboardFrame.cgRectValue
    }
}

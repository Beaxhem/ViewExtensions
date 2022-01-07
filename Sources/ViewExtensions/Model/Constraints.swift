//
//  Constraints.swift
//  
//
//  Created by Ilya Senchukov on 27.12.2021.
//

import UIKit

class Constraints {

    var topConstraint: NSLayoutConstraint?
    var leadingConstraint: NSLayoutConstraint?
    var trailingConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?
    var centerXConstraint: NSLayoutConstraint?
    var centerYConstraint: NSLayoutConstraint?

    init(
        topConstraint: NSLayoutConstraint? = nil,
        leadingConstraint: NSLayoutConstraint? = nil,
        trailingConstraint: NSLayoutConstraint? = nil,
        bottomConstraint: NSLayoutConstraint? = nil,
        heightConstraint: NSLayoutConstraint? = nil,
        widthConstraint: NSLayoutConstraint? = nil,
        centerXConstraint: NSLayoutConstraint? = nil,
        centerYConstraint: NSLayoutConstraint? = nil
    ) {
        self.topConstraint = topConstraint
        self.leadingConstraint = leadingConstraint
        self.trailingConstraint = trailingConstraint
        self.bottomConstraint = bottomConstraint
        self.heightConstraint = heightConstraint
        self.widthConstraint = widthConstraint
        self.centerXConstraint = centerXConstraint
        self.centerYConstraint = centerYConstraint

        activate(constraints: [
            topConstraint,
            leadingConstraint,
            trailingConstraint,
            bottomConstraint,
            heightConstraint,
            widthConstraint,
            centerXConstraint,
            centerYConstraint
        ])
    }

    func update(top: CGFloat? = nil,
                leading: CGFloat? = nil,
                trailing: CGFloat? = nil,
                bottom: CGFloat? = nil,
                height: CGFloat? = nil,
                width: CGFloat? = nil,
                centerX: CGFloat? = nil,
                centerY: CGFloat? = nil
    ) {
        if let top = top {
            topConstraint?.constant = top
        }
        if let leading = leading {
            leadingConstraint?.constant = leading
        }
        if let trailing = trailing {
            trailingConstraint?.constant = trailing
        }
        if let bottom = bottom {
            bottomConstraint?.constant = bottom
        }
        if let height = height {
            heightConstraint?.constant = height
        }
        if let width = width {
            widthConstraint?.constant = width
        }
        if let centerX = centerX {
            centerXConstraint?.constant = centerX
        }
        if let centerY = centerY {
            centerYConstraint?.constant = centerY
        }
    }

    func activate(constraints: [NSLayoutConstraint?]) {
        for constraint in constraints {
            constraint?.isActive = true
        }
    }
}

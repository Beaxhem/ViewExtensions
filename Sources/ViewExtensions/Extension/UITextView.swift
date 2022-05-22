//
//  UITextView.swift
//  
//
//  Created by Ilya Senchukov on 22.04.2022.
//

import UIKit

public extension UITextView {

	func setRoundedFont() {
		if let currentFont = font,
		   let descriptor = currentFont.fontDescriptor.withDesign(.rounded) {
			font = UIFont(descriptor: descriptor, size: currentFont.pointSize)
		}
	}

}

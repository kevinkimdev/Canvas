//
//  LoginTextField.swift
//  Canvas
//
//  Created by Sam Soffes on 11/26/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

final class LoginTextField: UITextField {

	// MARK: - Properties

	override var placeholder: String? {
		didSet {
			guard let placeholder = placeholder, font = font else { return }
			attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
				NSFontAttributeName: font,
				NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.4)
			])
		}
	}

	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = Color.brand.colorWithAlphaComponent(0.9)
		textColor = Color.white
		tintColor = Color.white
		font = Font.sansSerif()

		layer.borderColor = Color.white.CGColor
		layer.borderWidth = 2
		layer.cornerRadius = 4
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UITextField

	override func textRectForBounds(bounds: CGRect) -> CGRect {
		return CGRectInset(bounds, 12, 12)
	}

	override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
		return textRectForBounds(bounds)
	}

	override func editingRectForBounds(bounds: CGRect) -> CGRect {
		return textRectForBounds(bounds)
	}

	override func rightViewRectForBounds(bounds: CGRect) -> CGRect {
		var rect = super.rightViewRectForBounds(bounds)
		rect.origin.x -= 6
		return rect
	}
}

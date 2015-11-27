//
//  AlertController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/27/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class AlertController: UIAlertController {

	// MARK: - Properties

	var primaryAction: (Void -> Void)?
	

	// MARK: - UIResponder

	override func canBecomeFirstResponder() -> Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand]? {
		return (super.keyCommands ?? []) + [
			UIKeyCommand(input: "\r", modifierFlags: [], action: "selectFirstAction:")
		]
	}


	// MARK: - Actions

	func selectFirstAction(sender: AnyObject?) {
		primaryAction?()
		dismissViewControllerAnimated(true, completion: nil)
	}
}

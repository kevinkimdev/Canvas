//
//  EditorViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit
import CanvasText

class EditorViewController: UIViewController, Accountable {
	
	// MARK: - Properties

	var account: Account
	let canvas: Canvas
	
	let textView: TextView = {
		let view = TextView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 32, right: 16)
		view.alwaysBounceVertical = true
		view.editable = false
		return view
	}()
	
	private let textController: TextController


	// MARK: - Initializers

	init(account: Account, canvas: Canvas) {
		self.account = account
		self.canvas = canvas
		self.textController = TextController()
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIResponder

	override func canBecomeFirstResponder() -> Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand] {
		return [
			UIKeyCommand(input: UIKeyInputEscape, modifierFlags: [], action: "dismissKeyboard:")
		]
	}

	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .whiteColor()

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share:")
		
		textView.delegate = self
		view.addSubview(textView)
		
		NSLayoutConstraint.activateConstraints([
			textView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			textView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			textView.topAnchor.constraintEqualToAnchor(view.topAnchor),
			textView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
		])
		
		textController.delegate = self
		textController.connect(accessToken: account.accessToken, collectionID: canvas.collectionID, canvasID: canvas.ID) { webView in
			webView.alpha = 0.01
			self.view.addSubview(webView)
		}
	}


	// MARK: - Actions

	@objc private func dismissKeyboard(sender: AnyObject?) {
		textView.resignFirstResponder()
	}

	@objc private func share(sender: AnyObject?) {

	}

	@objc private func openInSafari(sender: AnyObject?) {
		guard let URL = NSURL(string: "https://usecanvas.com/\(canvas.collectionID)/-/\(canvas.shortID)") else { return }
		UIApplication.sharedApplication().openURL(URL)
	}
}


extension EditorViewController: UITextViewDelegate {
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		textController.change(range: range, replacementText: text)
		return true
	}
	
	func textViewDidChangeSelection(textView: UITextView) {
		textController.backingSelection = textController.displayRangeToBackingRange(textView.selectedRange)
	}
}


extension EditorViewController: TextControllerDelegate {
	func textControllerDidChangeText(textController: TextController) {
		textView.editable = true
		
		let text = NSMutableAttributedString(string: textController.displayText, attributes: Theme.baseAttributes)

		let count = textController.blocks.count
		for (i, block) in textController.blocks.enumerate() {
			let nextBlock: Block?
			if i < count - 2 {
				nextBlock = textController.blocks[i + 1]
			} else {
				nextBlock = nil
			}

			let attributes = Theme.attributesForBlock(block, nextBlock: nextBlock)
			let range = textController.backingRangeToDisplayRange(block.contentRange)
			text.addAttributes(attributes, range: range)
		}
		
		textView.attributedText = text
	}
	
	func textControllerDidUpdateSelection(textController: TextController) {
		textView.selectedRange = textController.displaySelection
	}
}

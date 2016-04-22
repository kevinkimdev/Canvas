//
//  TextStorage.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/4/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

typealias Style = (range: NSRange, attributes: Attributes)

protocol TextStorageDelegate: class {
	func textStorage(textStorage: TextStorage, didReplaceCharactersInRange range: NSRange, withString string: String)
}

class TextStorage: BaseTextStorage {

	// MARK: - Properties

	weak var textController: TextController?
	weak var replacementDelegate: TextStorageDelegate?

	private var styles = [Style]()
	private var invalidDisplayRange: NSRange?


	// MARK: - Updating Content

	func actuallyReplaceCharactersInRange(range: NSRange, withString string: String) {
		super.replaceCharactersInRange(range, withString: string)
		
		// Calculate the line range
		let text = self.string as NSString
		var lineRange = range
		lineRange.length = (string as NSString).length
		lineRange = text.lineRangeForRange(lineRange)
		
		// Include the line before
		if lineRange.location > 0 {
			lineRange.location -= 1
			lineRange.length += 1
		}
		
		invalidDisplayRange = lineRange
	}


	// MARK: - Styles

	func addStyles(styles: [Style]) {
		self.styles += styles
	}

	func applyStyles() {
		guard !styles.isEmpty else { return }

		for style in styles {
			if NSMaxRange(style.range) > storage.length {
				print("WARNING: Invalid style: \(style.range)")
				continue
			}
			storage.setAttributes(style.attributes, range: style.range)
			edited(.EditedAttributes, range: style.range, changeInLength: 0)
		}

		styles.removeAll()
	}


	// MARK: - NSTextStorage

	override func replaceCharactersInRange(range: NSRange, withString string: String) {
		// Local changes are delegated to the text controller
		replacementDelegate?.textStorage(self, didReplaceCharactersInRange: range, withString: string)
	}

	override func processEditing() {
		applyStyles()
		
		super.processEditing()

		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			self?.invalidateLayoutIfNeeded()
		}
	}


	// MARK: - Private

	private func invalidateLayoutIfNeeded() {
		guard let invalidDisplayRange = invalidDisplayRange else { return }

		for layoutManager in layoutManagers {
			layoutManager.ensureGlyphsForCharacterRange(invalidDisplayRange)
			layoutManager.invalidateLayoutForCharacterRange(invalidDisplayRange, actualCharacterRange: nil)
		}
		self.invalidDisplayRange = nil
	}
}

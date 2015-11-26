//
//  TextView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/17/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit
import CanvasText

class TextView: UITextView {

	// MARK: - Properties

	private var annotations = [UIView]()
	private var imageAttachments = [Image: NSTextAttachment]()


	// MARK: - Initializers {

	init(textStorage: NSTextStorage) {
		let layoutManager = NSLayoutManager()
		let container = NSTextContainer()
		layoutManager.addTextContainer(container)
		textStorage.addLayoutManager(layoutManager)

		super.init(frame: .zero, textContainer: container)

		alwaysBounceVertical = true
		keyboardDismissMode = .Interactive

		if let textStorage = textStorage as? CanvasTextStorage {
			textStorage.canvasDelegate = self
		}
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - Annotations

	func updateAnnotations() {
		annotations.removeAll()
//		imageAttachments.removeAll()

		// Add annotations
		let needsFirstResponder = !isFirstResponder()
		if needsFirstResponder {
			becomeFirstResponder()
		}

		guard let textStorage = textStorage as? CanvasTextStorage else { return }

		var orderedIndentationCounts = [Indentation: UInt]()

		for node in textStorage.nodes {
			if node is Listable {
				if let node = node as? OrderedList {
					let value = orderedIndentationCounts[node.indentation] ?? 0
					orderedIndentationCounts[node.indentation] = value + 1
				}
			} else {
				orderedIndentationCounts.removeAll()
			}

			if node.hasAnnotation, let annotation = annotationForNode(node, orderedIndentationCounts: orderedIndentationCounts) {
				addAnnotation(annotation)
			}
		}

		if needsFirstResponder {
			resignFirstResponder()
		}
	}


	// MARK: - Private

	private func addAnnotation(annotation: UIView) {
		annotations.append(annotation)
		addSubview(annotation)
	}

	private func annotationForNode(node: Node, orderedIndentationCounts: [Indentation: UInt]) -> UIView? {
		guard let textStorage = textStorage as? CanvasTextStorage else { return nil }

		let range = textStorage.backingRangeToDisplayRange(node.contentRange)

		guard let start = positionFromPosition(beginningOfDocument, offset: range.location),
			end = positionFromPosition(start, offset: range.length),
			textRange = textRangeFromPosition(start, toPosition: end)
		else { return nil }

		var rect = firstRectForRange(textRange)

		let theme = textStorage.theme
		let font = theme.fontOfSize(theme.fontSize, style: [])

		// Unordered List
		if let node = node as? UnorderedList {
			let view = BulletView(frame: .zero, unorderedList: node)
			let size = view.intrinsicContentSize()
			rect.origin.x -= theme.listIndentation - (size.width / 2)
			rect.origin.y = floor(rect.origin.y + font.ascender - (size.height / 2))
			rect.size = size
			view.frame = rect
			return view
		}

		// Ordered list
		if let node = node as? OrderedList {
			let value = orderedIndentationCounts[node.indentation] ?? 1
			let view = NumberView(frame: .zero, theme: theme, value: value)
			view.sizeToFit()

			let size = view.bounds.size
			let baseline = rect.maxY + font.descender
			let numberBaseline = size.height + view.font!.descender
			let scale = window!.screen.scale

			rect.origin.x -= size.width + 4
			rect.origin.y = ceil((baseline - numberBaseline) * scale) / scale
			rect.size = size
			view.frame = rect
			return view
		}

		// Checklist
		if let node = node as? Checklist {
			let view = CheckboxView(frame: .zero, checklist: node)
			let size = view.intrinsicContentSize()
			rect.origin.x -= theme.listIndentation
			rect.origin.y = floor(rect.origin.y + font.ascender - (size.height / 2))
			rect.size = size
			view.frame = rect
			return view
		}

		// Blockquote
		if node is Blockquote {
			let view = BlockquoteBorderView(frame: .zero)
			rect.origin.x -= theme.listIndentation
			rect.size.width = 4
			view.frame = rect
			return view
		}

		return nil
	}
}


extension TextView: CanvasTextStorageDelegate {
	func textStorageDidUpdateNodes(textStorage: CanvasTextStorage) {
		updateAnnotations()
	}

	func textStorage(textStorage: CanvasTextStorage, attachmentForAttachable node: Attachable) -> NSTextAttachment? {
		guard let image = node as? Image else { return nil }
		let attachment = NSTextAttachment()

		// Not sure why it’s off by 10 here
		let width = textContainer.size.width - 10
		attachment.bounds = CGRect(x: 0, y: 0, width: width, height: width * image.size.height / image.size.width)

		// Draw a custom placeholder *sigh*
		attachment.image = Image.placeholderImage(size: attachment.bounds.ceil.size)

		imageAttachments[image] = attachment

		ImagesController.sharedController.image(node: image) { [weak self] node, image in
			if let image = image, attachment = self?.imageAttachments[node], textStorage = self?.textStorage as? CanvasTextStorage {
				attachment.image = image

				let range = textStorage.backingRangeToDisplayRange(node.contentRange)
				textStorage.edited([.EditedAttributes], range: range, changeInLength: 0)
			}
		}

		return attachment
	}
}
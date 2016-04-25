//
//  TextController.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/2/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import WebKit
import OperationTransport
import CanvasNative

public protocol TextControllerConnectionDelegate: class {
	func textController(textController: TextController, willConnectWithWebView webView: WKWebView)
	func textControllerDidConnect(textController: TextController)
	func textController(textController: TextController, didDisconnectWithErrorMessage errorMessage: String?)
}

public protocol TextControllerSelectionDelegate: class {
	func textControllerDidUpdateSelectedRange(textController: TextController)
}

public protocol TextControllerAnnotationDelegate: class {
	func textController(textController: TextController, willAddAnnotation annotation: Annotation)
}


public final class TextController {

	// MARK: - Properties

	public weak var connectionDelegate: TextControllerConnectionDelegate?
	public weak var selectionDelegate: TextControllerSelectionDelegate?
	public weak var annotationDelegate: TextControllerAnnotationDelegate?

	public var textStorage: NSTextStorage {
		return _textStorage
	}

	let _textStorage = TextStorage()

	public let layoutManager: NSLayoutManager
	public let textContainer: NSTextContainer

	public var presentationString: String {
		return textStorage.string
	}

	public var backingString: String {
		return documentController.document.backingString
	}

	public var presentationSelectedRange: NSRange? {
		didSet {
			selectionDelegate?.textControllerDidUpdateSelectedRange(self)
		}
	}

	public var focusedBlock: BlockNode? {
		let selection = presentationSelectedRange
		return selection.flatMap { documentController.document.blockAt(presentationLocation: $0.location) }
	}

	public var textContainerInset: EdgeInsets = .zero {
		didSet {
			annotationsController.textContainerInset = textContainerInset
		}
	}

	public var horizontalSizeClass: UserInterfaceSizeClass = .Unspecified {
		didSet {
			annotationsController.horizontalSizeClass = horizontalSizeClass
		}
	}

	public var theme: Theme

	private var transportController: TransportController?
	private let annotationsController: AnnotationsController

	let documentController = DocumentController()

	let serverURL: NSURL
	let accessToken: String
	let organizationID: String
	let canvasID: String


	// MARK: - Initializers

	public init(serverURL: NSURL, accessToken: String, organizationID: String, canvasID: String, theme: Theme = LightTheme()) {
		self.serverURL = serverURL
		self.accessToken = accessToken
		self.organizationID = organizationID
		self.canvasID = canvasID
		self.theme = theme

		let layoutManager = LayoutManager()
		self.layoutManager = layoutManager

		let textContainer = TextContainer()
		self.textContainer = textContainer

		annotationsController = AnnotationsController(theme: theme)
		annotationsController.textController = self
		annotationsController.delegate = self

		// Configure Text Kit
		textContainer.textController = self
		layoutManager.textController = self
		_textStorage.textController = self
		_textStorage.replacementDelegate = self
		layoutManager.addTextContainer(textContainer)
		textStorage.addLayoutManager(layoutManager)

		documentController.delegate = self
	}


	// MARK: - OT

	public func connect() {
		if connectionDelegate == nil {
			print("[TextController] WARNING: connectionDelegate is nil. If you don't add the web view from textController:willConnectWithWebView: to a view, Operation Transport won't work as expected.")
		}

		let transportController = TransportController(serverURL: serverURL, accessToken: accessToken, organizationID: organizationID, canvasID: canvasID)
		transportController.delegate = self
		transportController.connect()
		self.transportController = transportController
	}


	// MARK: - Private

	private func stylesForBlock(block: BlockNode) -> [Style] {
		let blockStyle = Style(
			range: documentController.document.presentationRange(backingRange: block.visibleRange),
			attributes: theme.attributes(block: block)
		)

		var styles = [blockStyle]

		if let container = block as? NodeContainer, font = blockStyle.attributes[NSFontAttributeName] as? Font {
			styles += stylesForSpans(container.subnodes, currentFont: font)
		}

		return styles
	}

	private func stylesForSpans(spans: [SpanNode], currentFont: Font) -> [Style] {
		var styles = [Style]()

		for span in spans {
			guard let attributes = theme.attributes(span: span, currentFont: currentFont) else { continue }

			let style = Style(
				range: documentController.document.presentationRange(backingRange: span.visibleRange),
				attributes: attributes
			)
			styles.append(style)

			let font = attributes[NSFontAttributeName] as? Font ?? currentFont
			let foldableAttributes = theme.foldingAttributes(currentFont: font)

			// Foldable attributes
			if let foldable = span as? Foldable {
				// Forward the background color
				var attrs = foldableAttributes
				attrs[NSBackgroundColorAttributeName] = attributes[NSBackgroundColorAttributeName]

				for backingRange in foldable.foldableRanges {
					let style = Style(
						range: documentController.document.presentationRange(backingRange: backingRange),
						attributes: attrs
					)
					styles.append(style)
				}
			}

			// Special case for link URL and title. Maybe we should consider having Themes emit Styles instead of
			// attributes or at least have a style controller for all of this logic.
			if let link = span as? Link {
				// TODO: Derive from theme
				var attrs = foldableAttributes
				attrs[NSForegroundColorAttributeName] = Color(red: 0.420, green: 0.420, blue: 0.447, alpha: 1)

				styles.append(Style(range: documentController.document.presentationRange(backingRange: link.urlRange), attributes: attrs))

				if let title = link.title {
					styles.append(Style(range: documentController.document.presentationRange(backingRange: title.textRange), attributes: attrs))
				}
			}

			if let container = span as? NodeContainer {
				styles += stylesForSpans(container.subnodes, currentFont: font)
			}
		}

		return styles
	}

	func submitOperations(backingRange backingRange: NSRange, string: String) {
		guard let transportController = transportController else {
			print("[TextController] WARNING: Tried to submit an operation without a connection.")
			return
		}

		// Insert
		if backingRange.length == 0 {
			transportController.submitOperation(.Insert(location: UInt(backingRange.location), string: string))
			return
		}

		// Remove
		transportController.submitOperation(.Remove(location: UInt(backingRange.location), length: UInt(backingRange.length)))

		// Insert after removing
		if backingRange.length > 0 {
			transportController.submitOperation(.Insert(location: UInt(backingRange.location), string: string))
		}
	}
}


extension TextController: TransportControllerDelegate {
	public func transportController(controller: TransportController, willConnectWithWebView webView: WKWebView) {
		connectionDelegate?.textController(self, willConnectWithWebView: webView)
	}

	public func transportController(controller: TransportController, didReceiveSnapshot text: String) {
		let bounds = NSRange(location: 0, length: (documentController.document.backingString as NSString).length)

		// Ensure we have a valid document
		var string = text
		if string.isEmpty {
			string = Title.nativeRepresentation()
			submitOperations(backingRange: bounds, string: string)
		}

		documentController.replaceCharactersInRange(bounds, withString: string)
		connectionDelegate?.textControllerDidConnect(self)
	}

	public func transportController(controller: TransportController, didReceiveOperation operation: Operation) {
		switch operation {
		case .Insert(let location, let string):
			let range = NSRange(location: Int(location), length: 0)
			documentController.replaceCharactersInRange(range, withString: string)

		case .Remove(let location, let length):
			let range = NSRange(location: Int(location), length: Int(length))
			documentController.replaceCharactersInRange(range, withString: "")
		}
	}

	public func transportController(controller: TransportController, didReceiveWebErrorMessage errorMessage: String?, lineNumber: UInt?, columnNumber: UInt?) {
		print("TransportController error \(errorMessage)")
		connectionDelegate?.textController(self, didDisconnectWithErrorMessage: errorMessage)
	}

	public func transportController(controller: TransportController, didDisconnectWithErrorMessage errorMessage: String?) {
		print("TransportController disconnect \(errorMessage)")
		connectionDelegate?.textController(self, didDisconnectWithErrorMessage: errorMessage)
	}
}


extension TextController: DocumentControllerDelegate {
	public func documentControllerWillUpdateDocument(controller: DocumentController) {
		textStorage.beginEditing()
	}

	public func documentController(controller: DocumentController, didReplaceCharactersInPresentationStringInRange range: NSRange, withString string: String) {
		_textStorage.actuallyReplaceCharactersInRange(range, withString: string)

		let stringLength = (string as NSString).length
		if var selectedRange = presentationSelectedRange {
			selectedRange.location += stringLength
			selectedRange.location -= range.length
			presentationSelectedRange = selectedRange
		}
	}

	public func documentController(controller: DocumentController, didInsertBlock block: BlockNode, atIndex index: Int) {
		annotationsController.insert(block: block, index: index)
		_textStorage.addStyles(stylesForBlock(block))
	}

	public func documentController(controller: DocumentController, didRemoveBlock block: BlockNode, atIndex index: Int) {
		annotationsController.remove(block: block, index: index)
	}

	public func documentControllerDidUpdateDocument(controller: DocumentController) {
		textStorage.endEditing()

		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			self?.refreshAnnotations()
		}
	}

	private func refreshAnnotations() {
		let blocks = documentController.document.blocks

		// Refresh models
		for (i, block) in blocks.enumerate() {
			guard let block = block as? Annotatable else { continue }
			annotationsController.update(block: block, index: i)
		}

		// Layout
		annotationsController.layoutAnnotations()
	}
}


extension TextController: AnnotationsControllerDelegate {
	func annotationsController(annotationsController: AnnotationsController, willAddAnnotation annotation: Annotation) {
		annotationDelegate?.textController(self, willAddAnnotation: annotation)
	}
}


extension TextController: TextStorageDelegate {
	func textStorage(textStorage: TextStorage, didReplaceCharactersInRange range: NSRange, withString string: String) {
		let document = documentController.document
		var presentationRange = range
		var backingRange = document.backingRange(presentationRange: presentationRange)
		var replacement = string

		if string == "\n" {
			// Continue the previous node
			if let block = document.blockAt(backingLocation: backingRange.location) as? ReturnCompletable {
				// Bust out of completion
				if block.visibleRange.length == 0 {
					backingRange = block.range
					replacement = ""
				} else {
					// Complete the node
					if let block = block as? NativePrefixable {
						replacement += (document.backingString as NSString).substringWithRange(block.nativePrefixRange)

						// Make checkboxes unchecked by default
						replacement = replacement.stringByReplacingOccurrencesOfString("- [x] ", withString: "- [ ] ")
					}
				}
			}

			// Code block
			else {
				let text = document.backingString as NSString
				let lineRange = text.lineRangeForRange(backingRange)
				let line = text.substringWithRange(lineRange)

				// TODO: Support language
				if line.hasPrefix("```") {
					backingRange = NSUnionRange(lineRange, backingRange)
					replacement = CodeBlock.nativeRepresentation() + "\n"
				}
			}
		}

		edit(backingRange: backingRange, replacement: replacement)

		presentationRange.length = (replacement as NSString).length
		processMarkdownShortcuts(presentationRange)
	}

	// Commit the edit to DocumentController and submit the operation to OT. This doesn't go through the text system so
	// things like markdown shortcuts and return completion don't run on this change. Ideally, this will only be used
	// by the text storage delegate or changes made to non-visible portions of the backing string (like sblock or
	// indentation changes).
	func edit(backingRange backingRange: NSRange, replacement: String) {
		documentController.replaceCharactersInRange(backingRange, withString: replacement)
		submitOperations(backingRange: backingRange, string: replacement)
	}
}

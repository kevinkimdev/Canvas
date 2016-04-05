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
		return canvasController.string
	}

	public var presentationSelectedRange: NSRange? {
		didSet {
			selectionDelegate?.textControllerDidUpdateSelectedRange(self)
		}
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

	let canvasController = Controller()


	// MARK: - Initializers

	public init(theme: Theme = LightTheme()) {
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

		canvasController.delegate = self
	}


	// MARK: - OT

	public func connect(serverURL serverURL: NSURL, accessToken: String, organizationID: String, canvasID: String) {
		guard self.transportController == nil else { return }

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
			range: canvasController.presentationRange(backingRange: block.visibleRange),
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
				range: canvasController.presentationRange(backingRange: span.visibleRange),
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
						range: canvasController.presentationRange(backingRange: backingRange),
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

				styles.append(Style(range: canvasController.presentationRange(backingRange: link.urlRange), attributes: attrs))

				if let title = link.title {
					styles.append(Style(range: canvasController.presentationRange(backingRange: title.textRange), attributes: attrs))
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
		let bounds = NSRange(location: 0, length: canvasController.length)

		// Ensure we have a valid document
		var string = text
		if string.isEmpty {
			string = Title.nativeRepresentation()
			submitOperations(backingRange: bounds, string: string)
		}

		canvasController.replaceCharactersInRange(bounds, withString: string)
	}

	public func transportController(controller: TransportController, didReceiveOperation operation: Operation) {
		switch operation {
		case .Insert(let location, let string):
			let range = NSRange(location: Int(location), length: 0)
			canvasController.replaceCharactersInRange(range, withString: string)

		case .Remove(let location, let length):
			let range = NSRange(location: Int(location), length: Int(length))
			canvasController.replaceCharactersInRange(range, withString: "")
		}
	}

	public func transportController(controller: TransportController, didReceiveWebErrorMessage errorMessage: String?, lineNumber: UInt?, columnNumber: UInt?) {
		print("TransportController error \(errorMessage)")
	}

	public func transportController(controller: TransportController, didDisconnectWithErrorMessage errorMessage: String?) {
		print("TransportController disconnect \(errorMessage)")
	}
}


extension TextController: ControllerDelegate {
	public func controllerWillUpdateNodes(controller: Controller) {
		textStorage.beginEditing()
	}

	public func controller(controller: Controller, didReplaceCharactersInPresentationStringInRange range: NSRange, withString string: String) {
		_textStorage.actuallyReplaceCharactersInRange(range, withString: string)

		if var selectedRange = presentationSelectedRange {
			selectedRange.location += (string as NSString).length
			selectedRange.location -= range.length
			presentationSelectedRange = selectedRange
		}
	}

	public func controller(controller: Controller, didInsertBlock block: BlockNode, atIndex index: Int) {
		annotationsController.insert(block: block, index: index)
		_textStorage.addStyles(stylesForBlock(block))
//		layoutManager.invalidateLayoutForCharacterRange(controller.presentationRange(backingRange: block.visibleRange), actualCharacterRange: nil)
	}

	public func controller(controller: Controller, didRemoveBlock block: BlockNode, atIndex index: Int) {
		annotationsController.remove(block: block, index: index)
	}

	public func controller(controller: Controller, didReplaceContentForBlock before: BlockNode, atIndex index: Int, withBlock after: BlockNode) {
		annotationsController.replace(block: after, index: index)
		_textStorage.addStyles(stylesForBlock(after))
//		layoutManager.invalidateGlyphsForCharacterRange(controller.presentationRange(backingRange: after.visibleRange), changeInLength: after.visibleRange.length - before.visibleRange.length, actualCharacterRange: nil)
	}

	public func controller(controller: Controller, didUpdateLocationForBlock before: BlockNode, atIndex index: Int, withBlock after: BlockNode) {
		annotationsController.update(block: after, index: index)
//		layoutManager.invalidateLayoutForCharacterRange(controller.presentationRange(backingRange: after.visibleRange), actualCharacterRange: nil)
	}

	public func controllerDidUpdateNodes(controller: Controller) {
		textStorage.endEditing()
	}
}


extension TextController: AnnotationsControllerDelegate {
	func annotationsController(annotationsController: AnnotationsController, willAddAnnotation annotation: Annotation) {
		annotationDelegate?.textController(self, willAddAnnotation: annotation)
	}
}


extension TextController: TextStorageDelegate {
	func textStorage(textStorage: TextStorage, didReplaceCharactersInRange range: NSRange, withString string: String) {
		let backingRange = canvasController.backingRange(presentationRange: range)
		canvasController.replaceCharactersInRange(backingRange, withString: string)
		submitOperations(backingRange: backingRange, string: string)
	}
}

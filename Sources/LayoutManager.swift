//
//  LayoutManager.swift
//  CanvasText
//
//  Created by Sam Soffes on 1/22/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import CanvasNative

public protocol LayoutManagerDelegate: class {
	func layoutManagerDidInvalidateGlyphs(layoutManager: NSLayoutManager)
	func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer)
}

/// Custom layout mangaer to handle folding. Any range of text with the `FoldableAttributeName` set to `true`, will be
/// folded. To unfold a range, simply remove that attribute and call `invalidate`.
///
/// Consumers must not override the receiver's delegate property. If a consumer needs to get notified when layouts
/// complete, they should use the `layoutDelegate` property and corresponding `LayoutManagerDelegate` protocol.
///
/// Currently, folding is only supported on iOS although it should be trivial to add OS X support.
public class LayoutManager: NSLayoutManager {

	// MARK: - Properties

	public weak var layoutDelegate: LayoutManagerDelegate?

	public var unfoldedRange: NSRange? {
		didSet {
			if let unfoldedRange = unfoldedRange, oldValue = oldValue where !unfoldedRange.equals(oldValue) {
				unfolding = true
				invalidateGlyphs()
				return
			}

			if let unfoldedRange = unfoldedRange {
				unfolding = !foldedIndices.intersect(unfoldedRange.indices).isEmpty
			} else {
				unfolding = false
			}

			invalidateGlyphsIfNeeded()
		}
	}

	public var foldableRanges = [NSRange]() {
		didSet {
//			if let textStorage = textStorage as? CanvasTextStorage {
//				let indicies = foldableRanges.map { textStorage.backingRangeToDisplayRange($0).indices }
//				foldedIndices = Set(indicies.flatten())
//			}

			invalidateGlyphs()
		}
	}

	private var needsInvalidateGlyphs = false
	private var foldedIndices = Set<Int>()
	private var unfolding = false {
		didSet {
			guard unfolding != oldValue else { return }
			setNeedsInvalidateGlyphs()
		}
	}


	// MARK: - Initializers

	public override init() {
		super.init()
		initialize()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		initialize()
	}


	// MARK: - Private

	private func initialize() {
		delegate = self
	}

	// TODO: We should intellegently invalidate glyphs are a given range instead of the entire document.
	private func invalidateGlyphs() {
		guard let characterLength = textStorage?.length else { return }
		let characterRange = NSRange(location: 0, length: characterLength)
		invalidateGlyphsForCharacterRange(characterRange, changeInLength: 0, actualCharacterRange: nil)
		layoutDelegate?.layoutManagerDidInvalidateGlyphs(self)
		needsInvalidateGlyphs = false
	}

	private func setNeedsInvalidateGlyphs() {
		needsInvalidateGlyphs = true
	}

	private func invalidateGlyphsIfNeeded() {
		if needsInvalidateGlyphs {
			invalidateGlyphs()
		}
	}
}


extension LayoutManager: NSLayoutManagerDelegate {
	public func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
		guard let textContainer = textContainer else { return }
		layoutDelegate?.layoutManager(self, didCompleteLayoutForTextContainer: textContainer)
	}
}


#if os(iOS)
	extension LayoutManager {
		public func layoutManager(layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSGlyphProperty>, characterIndexes: UnsafePointer<Int>, font: UIFont, forGlyphRange glyphRange: NSRange) -> Int {
			let properties = UnsafeMutablePointer<NSGlyphProperty>(props)

			for i in 0..<glyphRange.length {
				let characterIndex = characterIndexes[i]

				if !(unfoldedRange?.contains(characterIndex) ?? false) && foldedIndices.contains(characterIndex) {
					properties[i] = .ControlCharacter
				}
			}

			layoutManager.setGlyphs(glyphs, properties: properties, characterIndexes: characterIndexes, font: font, forGlyphRange: glyphRange)
			return glyphRange.length
		}

		public func layoutManager(layoutManager: NSLayoutManager, shouldUseAction action: NSControlCharacterAction, forControlCharacterAtIndex characterIndex: Int) -> NSControlCharacterAction {
			// Don't advance if it's a control character we changed
			if foldedIndices.contains(characterIndex) {
				return .ZeroAdvancement
			}

			// Default action for things we didn't change
			return action
		}

//		public func layoutManager(layoutManager: NSLayoutManager, paragraphSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
//			let characterIndex = characterIndexForGlyphAtIndex(glyphIndex)
//			guard let textStorage = textStorage as? CanvasTextStorage, node = textStorage.blockNodeAtDisplayLocation(characterIndex) else { return 0 }
//			return textStorage.theme.blockSpacing(node: node, horizontalSizeClass: textStorage.horizontalSizeClass).marginBottom
//		}
	}
#endif

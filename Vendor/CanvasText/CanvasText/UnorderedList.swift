//
//  UnorderedListItem.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct UnorderedListItem: Listable, NodeContainer {

	// MARK: - Properties

	public var range: NSRange
	public var nativePrefixRange: NSRange
	public var displayRange: NSRange
	public var indentationRange: NSRange
	public var indentation: Indentation

	public var hasAnnotation: Bool {
		return true
	}

	public var textRange: NSRange {
		return displayRange
	}

	public var subnodes = [Node]()


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		guard let (nativePrefixRange, indentationRange, indentation, prefixRange, displayRange) = parseListable(string: string, enclosingRange: enclosingRange, delimiter: "unordered-list", prefix: "- ") else { return nil }

		range = enclosingRange
		self.nativePrefixRange = nativePrefixRange.union(prefixRange)
		self.displayRange = displayRange
		self.indentationRange = indentationRange
		self.indentation = indentation
	}


	// MARK: - Native

	public static func nativeRepresentation(indentation indentation: Indentation = .Zero) -> String {
		return "\(leadingNativePrefix)unordered-list-\(indentation.string)\(trailingNativePrefix)- "
	}
}


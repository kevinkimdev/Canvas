//
//  Paragraph.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Paragraph: BlockNode, NodeContainer {

	// MARK: - Properties

	public var range: NSRange
	public var enclosingRange: NSRange

	public var displayRange: NSRange {
		return range
	}

	public var textRange: NSRange {
		return range
	}

	public var subnodes = [Node]()

	public var dictionary: [String: AnyObject] {
		return [
			"type": "paragraph",
			"range": range.dictionary,
			"displayRange": displayRange.dictionary,
			"subnodes": subnodes.map { $0.dictionary }
		]
	}


	// MARK: - Initializers

	public init?(string: String, range: NSRange, enclosingRange: NSRange) {
		// Prevent any Canvas Native from appearing in the documment
		if string.hasPrefix(leadingNativePrefix) {
			return nil
		}

		self.range = range
		self.enclosingRange = enclosingRange
	}

	public init(range: NSRange, enclosingRange: NSRange? = nil, subnodes: [Node]) {
		self.range = range
		self.enclosingRange = enclosingRange ?? NSRange(location: range.location, length: range.length + 1)
		self.subnodes = subnodes
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		range.location += delta
		enclosingRange.location += delta
		
		subnodes = subnodes.map {
			var node = $0
			node.offset(delta)
			return node
		}
	}
}

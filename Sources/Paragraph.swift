//
//  Paragraph.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Paragraph: BlockNode, NodeContainer, Equatable {

	// MARK: - Properties

	public var range: NSRange

	public var visibleRange: NSRange {
		return range
	}

	public var textRange: NSRange {
		return range
	}

	public var subnodes = [SpanNode]()

	public var dictionary: [String: AnyObject] {
		return [
			"type": "paragraph",
			"range": range.dictionary,
			"visibleRange": visibleRange.dictionary,
			"subnodes": subnodes.map { $0.dictionary }
		]
	}


	// MARK: - Initializers

	public init?(string: String, range: NSRange) {
		// Prevent any Canvas Native from appearing in the documment
		if string.hasPrefix(leadingNativePrefix) {
			return nil
		}

		self.range = range
	}

	public init(range: NSRange, subnodes: [SpanNode]) {
		self.range = range
		self.subnodes = subnodes
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		range.location += delta
		
		subnodes = subnodes.map {
			var node = $0
			node.offset(delta)
			return node
		}
	}
}


public func ==(lhs: Paragraph, rhs: Paragraph) -> Bool {
	return NSEqualRanges(lhs.range, rhs.range)
}

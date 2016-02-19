//
//  Emphasis.swift
//  CanvasNative
//
//  Created by Sam Soffes on 1/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Emphasis: SpanNode, Foldable, NodeContainer {

	// MARK: - Properties

	public var leadingDelimiterRange: NSRange
	public var textRange: NSRange
	public var trailingDelimiterRange: NSRange

	public var range: NSRange {
		return leadingDelimiterRange.union(textRange).union(trailingDelimiterRange)
	}

	public var displayRange: NSRange {
		return range
	}

	public var foldableRanges: [NSRange] {
		return [
			leadingDelimiterRange,
			trailingDelimiterRange
		]
	}

	public var dictionary: [String: AnyObject] {
		return [
			"type": "emphasis",
			"range": range.dictionary,
			"displayRange": displayRange.dictionary,
			"leadingDelimiterRange": leadingDelimiterRange.dictionary,
			"textRange": textRange.dictionary,
			"trailingDelimiterRange": trailingDelimiterRange.dictionary,
			"subnodes": subnodes.map { $0.dictionary }
		]
	}

	public var subnodes = [Node]()


	// MARK: - Initializers

	public init(leadingDelimiterRange: NSRange, textRange: NSRange, trailingDelimiterRange: NSRange, subnodes: [Node] = []) {
		self.leadingDelimiterRange = leadingDelimiterRange
		self.textRange = textRange
		self.trailingDelimiterRange = trailingDelimiterRange
		self.subnodes = subnodes
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		leadingDelimiterRange.location += delta
		textRange.location += delta
		trailingDelimiterRange.location += delta

		subnodes = subnodes.map {
			var node = $0
			node.offset(delta)
			return node
		}
	}
}


extension Emphasis: SpanNodeParseable {
	static let regularExpression: NSRegularExpression! = try? NSRegularExpression(pattern: "(?:\\s|^)(\\*|_)(?=\\S)(.+?)(?<=\\S)(\\1)", options: [])

	init?(match: NSTextCheckingResult) {
		if match.numberOfRanges != 4 {
			return nil
		}

		leadingDelimiterRange = match.rangeAtIndex(1)
		textRange = match.rangeAtIndex(2)
		trailingDelimiterRange = match.rangeAtIndex(3)
	}
}

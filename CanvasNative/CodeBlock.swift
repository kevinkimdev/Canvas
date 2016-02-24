//
//  CodeBlock.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct CodeBlock: NativePrefixable, Positionable, Annotatable {

	// MARK: - Properties

	public var range: NSRange
	public var nativePrefixRange: NSRange
	public var displayRange: NSRange
	public var position: Position = .Single


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		guard let (nativePrefixRange, displayRange) = parseBlockNode(
			string: string,
			enclosingRange: enclosingRange,
			delimiter: "code"
		) else { return nil }

		range = enclosingRange
		self.nativePrefixRange = nativePrefixRange
		self.displayRange = displayRange
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		range.location += delta
		nativePrefixRange.location += delta
		displayRange.location += delta
	}


	// MARK: - Native

	public static func nativeRepresentation() -> String {
		return "\(leadingNativePrefix)code\(trailingNativePrefix)"
	}
}

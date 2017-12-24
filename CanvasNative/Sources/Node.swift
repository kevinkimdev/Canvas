//
//  Node.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol Node {
	/// Range of the entire node in the backing text
	var range: NSRange { get }

	/// Range of the node not hidden from display.
	var visibleRange: NSRange { get }

	/// Dictionary representation
	var dictionary: [String: Any] { get }

	/// Adjust all range locations by a delta.
	///
	/// - parameter delta: Amount to offset range locations
	mutating func offset(_ delta: Int)
}

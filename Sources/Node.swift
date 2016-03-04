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
	var dictionary: [String: AnyObject] { get }

	func contentInString(string: String) -> String

	/// Adjust all range locations by a delta.
	///
	/// - parameter delta: Amount to offset range locations
	mutating func offset(delta: Int)
}


extension Node {
	public func contentInString(string: String) -> String {
		return (string as NSString).substringWithRange(visibleRange)
	}
}

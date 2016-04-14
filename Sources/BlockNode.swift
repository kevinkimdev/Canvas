//
//  BlockNode.swift
//  CanvasNative
//
//  Created by Sam Soffes on 1/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol BlockNode: Node {
	var enclosingRange: NSRange { get }
	init?(string: String, range: NSRange, enclosingRange: NSRange)
}


extension BlockNode {
	var newLineRange: NSRange? {
		let delta = enclosingRange.max - range.max
		guard delta == 1 else { return nil }

		return NSRange(location: range.max, length: 1)
	}
}

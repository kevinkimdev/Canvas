//
//  NSRange+CanvasText.swift
//  Canvas
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

extension NSRange: Equatable {
	init(location: UInt, length: UInt) {
		self.init(location: Int(location), length: Int(length))
	}
	
	init(location: UInt, length: Int) {
		self.init(location: Int(location), length: length)
	}
	
	init(location: Int, length: UInt) {
		self.init(location: location, length: Int(length))
	}
	
	static var zero: NSRange {
		return NSRange(location: 0, length: 0)
	}
}


public func ==(lhs: NSRange, rhs: NSRange) -> Bool {
	return NSEqualRanges(lhs, rhs)
}

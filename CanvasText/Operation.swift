//
//  Operation.swift
//  Canvas
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

enum Operation {
	
	// MARK: - Cases
	
	case Insert(location: UInt, string: String)
	case Remove(location: UInt, length: UInt)
	
	
	// MARK: - Properties
	
	var NSRange: Foundation.NSRange {
		switch self {
		case .Insert(let location, _):
			return Foundation.NSRange(location: Int(location), length: 0)
		case .Remove(let location, let length):
			return Foundation.NSRange(location: Int(location), length: Int(length))
		}
	}
	
	
	// MARK: - Initializers
	
	init?(dictionary: [String: AnyObject]) {
		guard let type = dictionary["type"] as? String,
			location = dictionary["location"] as? UInt
			else { return nil }
		
		if let string = dictionary["text"] as? String where type == "insert" {
			self = .Insert(location: location, string: string)
			return
		}
		
		if let length = dictionary["length"] as? UInt where type == "remove" {
			self = .Remove(location: location, length: length)
			return
		}
		
		return nil
	}
	
	
	// MARK: - Range
	
	func rangeWithString(string: String) -> Range<String.Index> {
		switch self {
		case .Insert(let location, _):
			let start = string.startIndex.advancedBy(Int(location))
			return Range<String.Index>(start: start, end: start)
		case .Remove(let location, let length):
			let start = string.startIndex.advancedBy(Int(location))
			return Range<String.Index>(start: start, end: start.advancedBy(Int(length)))
		}
	}
}

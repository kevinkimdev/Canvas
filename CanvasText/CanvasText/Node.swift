//
//  Node.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol Node {

	var contentRange: NSRange { get }

	init?(string: String, enclosingRange: NSRange)

	func contentInString(string: String) -> String
}


extension Node {
	public func contentInString(string: String) -> String {
		return (string as NSString).substringWithRange(contentRange)
	}
}


func parseBlockNode(string string: String, enclosingRange: NSRange, delimiter: String) -> (delimiterRange: NSRange, contentRange: NSRange)? {
	let scanner = NSScanner(string: string)
	scanner.charactersToBeSkipped = nil

	// Delimiter
	if !scanner.scanString("\(leadingDelimiter)\(delimiter)\(trailingDelimiter)", intoString: nil) {
		return nil
	}
	let delimiterRange = NSRange(location: enclosingRange.location, length: scanner.scanLocation)

	// Content
	let contentRange = NSRange(location: enclosingRange.location + scanner.scanLocation, length: enclosingRange.length - scanner.scanLocation)

	return (delimiterRange, contentRange)
}


func parseBlockNode(string string: String, enclosingRange: NSRange, delimiter: String, prefix: String) -> (delimiterRange: NSRange, prefixRange: NSRange, contentRange: NSRange)? {
	let scanner = NSScanner(string: string)
	scanner.charactersToBeSkipped = nil

	// Delimiter
	if !scanner.scanString("\(leadingDelimiter)\(delimiter)\(trailingDelimiter)", intoString: nil) {
		return nil
	}
	let delimiterRange = NSRange(location: enclosingRange.location, length: scanner.scanLocation)

	// Prefix
	let startPrefix = scanner.scanLocation
	if !scanner.scanString(prefix, intoString: nil) {
		return nil
	}
	let prefixRange = NSRange(location: enclosingRange.location + startPrefix, length: scanner.scanLocation - startPrefix)

	// Content
	let contentRange = NSRange(location: enclosingRange.location + scanner.scanLocation, length: enclosingRange.length - scanner.scanLocation)

	return (delimiterRange, prefixRange, contentRange)
}

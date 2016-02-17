//
//  HeadingTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

class HeadingTest: XCTestCase {
	func testHeading1() {
		let node = Heading(string: "# Hello", enclosingRange: NSRange(location: 0, length: 7))!
		XCTAssertEqual(NSRange(location: 0, length: 2), node.leadingDelimiterRange)
		XCTAssertEqual(NSRange(location: 2, length: 5), node.textRange)
		XCTAssertEqual(NSRange(location: 0, length: 7), node.displayRange)
	}

	func testHeading2() {
		let node = Heading(string: "## Hello", enclosingRange: NSRange(location: 0, length: 8))!
		XCTAssertEqual(NSRange(location: 0, length: 3), node.leadingDelimiterRange)
		XCTAssertEqual(NSRange(location: 3, length: 5), node.textRange)
		XCTAssertEqual(NSRange(location: 0, length: 8), node.displayRange)
	}

	func testHeading7() {
		XCTAssertNil(Heading(string: "####### Hello", enclosingRange: NSRange(location: 0, length: 13)))
	}
}

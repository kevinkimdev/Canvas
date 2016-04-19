//
//  ListableTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

class ListableTests: XCTestCase {
	func testUncompleted() {
		let node = ChecklistItem(string: "⧙checklist-0⧘- [ ] Hello", range: NSRange(location: 0, length: 24), enclosingRange: NSRange(location: 0, length: 25))!
		XCTAssertEqual(NSRange(location: 0, length: 19), node.nativePrefixRange)
		XCTAssertEqual(NSRange(location: 19, length: 5), node.visibleRange)
		XCTAssertEqual(Indentation.Zero, node.indentation)
		XCTAssertEqual(ChecklistItem.State.Unchecked, node.state)
	}

	func testCompleted() {
		let node = ChecklistItem(string: "⧙checklist-1⧘- [x] Done", range: NSRange(location: 10, length: 23), enclosingRange: NSRange(location: 10, length: 24))!
		XCTAssertEqual(NSRange(location: 10, length: 19), node.nativePrefixRange)
		XCTAssertEqual(NSRange(location: 29, length: 4), node.visibleRange)
		XCTAssertEqual(Indentation.One, node.indentation)
		XCTAssertEqual(ChecklistItem.State.Checked, node.state)
	}

	func testUnordered() {
		let node = UnorderedListItem(string: "⧙unordered-list-0⧘- Hello", range: NSRange(location: 0, length: 25), enclosingRange: NSRange(location: 0, length: 26))!
		XCTAssertEqual(NSRange(location: 0, length: 20), node.nativePrefixRange)
		XCTAssertEqual(NSRange(location: 20, length: 5), node.visibleRange)
		XCTAssertEqual(Indentation.Zero, node.indentation)
	}

	func testOrdered() {
		let node = OrderedListItem(string: "⧙ordered-list-0⧘1. Hello", range: NSRange(location: 0, length: 24), enclosingRange: NSRange(location: 0, length: 25))!
		XCTAssertEqual(NSRange(location: 0, length: 19), node.nativePrefixRange)
		XCTAssertEqual(NSRange(location: 19, length: 5), node.visibleRange)
		XCTAssertEqual(Indentation.Zero, node.indentation)
	}

	func testMixedPositions() {
		let blocks = Parser.parse("⧙doc-heading⧘Positions\n⧙ordered-list-0⧘1. One\n⧙ordered-list-0⧘1. Two\n⧙checklist-0⧘- [ ] Hi\n⧙unordered-list-0⧘- Okay")
		let actual = blocks.flatMap { ($0 as? Positionable)?.position }

		let expected: [Position] = [
			.Top,
			.Bottom(2),
			.Single,
			.Single
		]

		XCTAssertEqual(actual, expected)
	}


	// https://github.com/usecanvas/CanvasNative/issues/14
	func testIndentationPosition() {
		let blocks = Parser.parse("⧙doc-heading⧘Positions\n⧙ordered-list-0⧘1. One\n⧙ordered-list-1⧘1. A\n⧙ordered-list-0⧘1. Two\n⧙ordered-list-1⧘1. Red\n⧙ordered-list-1⧘1. Green\n⧙ordered-list-1⧘1. Blue")
		let actual = blocks.flatMap { ($0 as? Positionable)?.position }

		let expected: [Position] = [
			.Top,
			.Single,
			.Middle(2),
			.Top,
			.Middle(2),
			.Bottom(3)
		]

		XCTAssertEqual(actual, expected)
	}
}

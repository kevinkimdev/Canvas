//
//  XCTestCase+CanvasNativeTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 3/10/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

extension XCTest {
	func parse(string: String) -> [[String: AnyObject]] {
		return Parser.parse(string).map { $0.dictionary }
	}

	func blockTypes(string: String) -> [String] {
		return Parser.parse(string).map { String($0.dynamicType) }
	}
}

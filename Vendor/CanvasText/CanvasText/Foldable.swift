//
//  Foldable.swift
//  CanvasText
//
//  Created by Sam Soffes on 1/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol Foldable {
	var foldableRanges: [NSRange] { get }
}

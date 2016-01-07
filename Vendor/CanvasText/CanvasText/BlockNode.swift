//
//  BlockNode.swift
//  CanvasText
//
//  Created by Sam Soffes on 1/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

public protocol BlockNode: Node {
	var hasAnnotation: Bool { get }
	var allowsReturnCompletion: Bool { get }
}


extension BlockNode {
	public var hasAnnotation: Bool {
		return false
	}

	public var allowsReturnCompletion: Bool {
		return true
	}
}


let blockLevelParseOrder: [BlockNode.Type] = [
	Blockquote.self,
	Checklist.self,
	CodeBlock.self,
	Title.self,
	Heading.self,
	Image.self,
	OrderedList.self,
	UnorderedList.self,
	Paragraph.self
]

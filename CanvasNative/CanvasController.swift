//
//  CanvasController.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/18/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol CanvasControllerDelegate: class {
	func canvasControllerWillUpdateNodes(canvasController: CanvasController)

	func canvasController(canvasController: CanvasController, didInsertBlock block: BlockNode, atIndex index: Int)

	func canvasController(canvasController: CanvasController, didRemoveBlock block: BlockNode, atIndex index: Int)

	// The block's content changed.
	func canvasController(canvasController: CanvasController, didReplaceContentForBlock before: BlockNode, atIndex index: Int, withBlock after: BlockNode)

	// The block's metadata changed.
	func canvasController(canvasController: CanvasController, didUpdateLocationForBlock before: BlockNode, atIndex index: Int, withBlock after: BlockNode)

	func canvasControllerDidUpdateNodes(canvasController: CanvasController)

	func canvasController(canvasController: CanvasController, didReplaceCharactersInPresentationStringInRange range: NSRange, withString string: String)
}


public final class CanvasController {

	// MARK: - Properties

	public weak var delegate: CanvasControllerDelegate?

	public private(set) var blocks = [BlockNode]()

	public var string: String {
		get {
			return text as String
		}

		set {
			replaceCharactersInRange(NSRange(location: 0, length: length), withString: newValue)
		}
	}

	public var length: Int {
		return text.length
	}

	private let text: NSMutableString = ""


	// MARK: - Initializers

	public init(string: String? = nil, delegate: CanvasControllerDelegate? = nil) {
		self.delegate = delegate

		if let string = string {
			self.string = string
		}
	}


	// MARK: - Changing Text

	public func replaceCharactersInRange(inRange: NSRange, withString inString: String) {
		var range = inRange
		let string = inString as NSString

		if range.length > 1 && text.substringWithRange(NSRange(location: range.location, length: 1)) == "\n" {
			range.location += 1
			range.length = min(length - range.location, range.length)
		}

		// Notify the delegate we're beginning
		willUpdate()

		// Calculate blocks changed by the edit
		let blockRange = blockRangeForCharacterRange(range, string: string as String)

		// Update the text representation
		text.replaceCharactersInRange(range, withString: string as String)

		let displayRange = presentationRange(blocks: blocks, backingRange: range)

		// Reparse the invalid range of document
		let invalidRange = parseRangeForRange(NSRange(location: range.location, length: string.length))
		let parsedBlocks = invalidRange.length == 0 ? [] : Parser.parse(text, range: invalidRange)
		blocks = applyParsedBlocks(parsedBlocks, parseRange: invalidRange, blockRange: blockRange)

		let displayTextRange = presentationRange(blocks: blocks, backingRange: NSRange(location: range.location, length: string.length - range.length))
		let displayString = blocks.map({ $0.contentInString(text as String) }).joinWithSeparator("\n") as NSString
		let replacement = displayString.substringWithRange(displayTextRange) as String
		delegate?.canvasController(self, didReplaceCharactersInPresentationStringInRange: displayRange, withString: replacement)

		// Notify the delegate we're done
		didUpdate()
	}


	// MARK: - Applying Changes to the Tree

	private func applyParsedBlocks(parsedBlocks: [BlockNode], parseRange: NSRange, blockRange: NSRange) -> [BlockNode] {
		// Start to calculate the new blocks
		var workingBlocks = blocks

		let afterRange: Range<Int>
		let afterOffset: Int

		let updatedBlocks = [BlockNode](blocks[blockRange.range])

		let blockDelta = parsedBlocks.count - updatedBlocks.count
		var replaced = 0

		// Inserting
		if blockDelta > 0 {
			for i in 0..<blockDelta {
				let block = parsedBlocks[i]
				let index = i + blockRange.location
				workingBlocks.insert(block, atIndex: index)
				replaced += 1
				didInsert(block: block, index: index)
			}
		}

		// Deleting
		if blockDelta < 0 {
			for _ in (blockRange.location)..<(blockRange.location - blockDelta) {
				let index = blockRange.location
				let block = workingBlocks[index]
				workingBlocks.removeAtIndex(index)
				didRemove(block: block, index: index)
			}
		}

		// Replace the remaining blocks
		for i in replaced..<parsedBlocks.count {
			let after = parsedBlocks[i]
			let index = i + blockRange.location
			let before = workingBlocks[index]
			workingBlocks.removeAtIndex(index)
			workingBlocks.insert(after, atIndex: index)
			didReplace(before: before, index: index, after: after)
		}

		afterOffset = Int(characterLengthOfBlocks(parsedBlocks)) - Int(characterLengthOfBlocks(updatedBlocks)) + blockDelta
		afterRange = (blockRange.max + blockDelta)..<workingBlocks.endIndex

		// Update blocks after edit
		workingBlocks = offsetBlocks(blocks: workingBlocks, blockRange: afterRange, offset: afterOffset)

		// TODO: Recalculate positionable

		return workingBlocks
	}

	private func offsetBlocks(blocks blocks: [BlockNode], blockRange: Range<Int>, offset: Int) -> [BlockNode] {
		var workingBlocks = blocks

		for index in blockRange {
			let before = workingBlocks[index]
			var after = before
			after.offset(offset)
			workingBlocks[index] = after
			didUpdate(before: before, index: index, after: after)
		}

		return workingBlocks
	}


	// MARK: - Range Calculations

	private func parseRangeForRange(range: NSRange) -> NSRange {
		var invalidRange = range

		if invalidRange.length == 0 {
			return invalidRange
		}

		let rangeMax = invalidRange.max

		for block in blocks {
			if block.enclosingRange.location >= rangeMax {
				break
			}

			if block.enclosingRange.max - 1 == invalidRange.location {
				invalidRange.location += 1
				invalidRange.length -= 1
				break
			}
		}

		return text.lineRangeForRange(invalidRange)
	}

	private func presentationRange(blocks blocks: [BlockNode], backingRange: NSRange) -> NSRange {
		var presentationRange = backingRange

		for block in blocks {
			guard let block = block as? NativePrefixable else { continue }

			let range = block.nativePrefixRange

//			if range.location > backingRange.location {
//				break
//			}

			if presentationRange.location > range.location {
				presentationRange.location -= range.length
			} else if presentationRange.intersection(range) != nil {
				presentationRange.length -= range.length
			}
		}

		return presentationRange
	}


	// MARK: - Block Calculations

	private func characterLengthOfBlocks(blocks: [BlockNode]) -> UInt {
		return blocks.map { UInt($0.range.length) }.reduce(0, combine: +)
	}

	func blockRangeForCharacterRange(range: NSRange, string: String) -> NSRange {
		var location: Int?
		var matchingBlocks = [BlockNode]()

		let hasNewLinePrefix = string.hasPrefix("\n")

		for (i, block) in blocks.enumerate() {
			if block.enclosingRange.intersection(range) != nil || block.enclosingRange.max == range.location && hasNewLinePrefix {
				// Detect inserting at the end of a line vs inserting a new block
				if block.newLineRange != nil && range.location == block.range.max && hasNewLinePrefix {
					return NSRange(location: min(i + 1, blocks.endIndex), length: 0)
				}

				// Start if we haven't already
				if location == nil {
					location = i
				}

				matchingBlocks.append(block)
			} else if location != nil {
				// This block didn't match and we've already started, so end the range.
				break
			}
		}

		// If we didn't find anything, assume we're inserting at the very end.
		let blockRange = NSRange(location: location ?? blocks.endIndex, length: matchingBlocks.count)

		// If we delete the new line in the last block, extend the length if possible.
//		if string.isEmpty, let lastNewLine = matchingBlocks.last?.newLineRange where lastNewLine.intersection(range) == 1 {
//			blockRange.length = min(blockRange.length + 1, blocks.count - blockRange.location)
//		}

		return blockRange
	}


	// MARK: - Delegate Calls

	private func willUpdate() {
		delegate?.canvasControllerWillUpdateNodes(self)
	}

	private func didUpdate() {
		delegate?.canvasControllerDidUpdateNodes(self)
	}

	private func didInsert(block block: BlockNode, index: Int) {
		delegate?.canvasController(self, didInsertBlock: block, atIndex: index)
	}

	private func didRemove(block block: BlockNode, index: Int) {
		delegate?.canvasController(self, didRemoveBlock: block, atIndex: index)
	}

	private func didReplace(before before: BlockNode, index: Int, after: BlockNode) {
		if before.dynamicType == after.dynamicType {
			delegate?.canvasController(self, didReplaceContentForBlock: before, atIndex: index, withBlock: after)
			return
		}

		didRemove(block: before, index: index)
		didInsert(block: after, index: index)
	}

	private func didUpdate(before before: BlockNode, index: Int, after: BlockNode) {
		delegate?.canvasController(self, didUpdateLocationForBlock: before, atIndex: index, withBlock: after)
	}
}

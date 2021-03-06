import Foundation

public struct Emphasis: SpanNode, Foldable, NodeContainer {

    // MARK: - Properties

	public var leadingDelimiterRange: NSRange
	public var textRange: NSRange
	public var trailingDelimiterRange: NSRange

	public var range: NSRange {
		return leadingDelimiterRange.union(textRange).union(trailingDelimiterRange)
	}

	public var visibleRange: NSRange {
		return range
	}

	public var foldableRanges: [NSRange] {
		return [
			leadingDelimiterRange,
			trailingDelimiterRange
		]
	}

	public var dictionary: [String: Any] {
		return [
			"type": "emphasis",
			"range": range.dictionary,
			"visibleRange": visibleRange.dictionary,
			"leadingDelimiterRange": leadingDelimiterRange.dictionary,
			"textRange": textRange.dictionary,
			"trailingDelimiterRange": trailingDelimiterRange.dictionary,
			"subnodes": subnodes.map { $0.dictionary }
		]
	}

	public var subnodes = [SpanNode]()

    // MARK: - Initializers

	public init(leadingDelimiterRange: NSRange, textRange: NSRange, trailingDelimiterRange: NSRange,
				subnodes: [SpanNode] = [])
	{
		self.leadingDelimiterRange = leadingDelimiterRange
		self.textRange = textRange
		self.trailingDelimiterRange = trailingDelimiterRange
		self.subnodes = subnodes
	}

    // MARK: - Node

	public mutating func offset(_ delta: Int) {
		leadingDelimiterRange.location += delta
		textRange.location += delta
		trailingDelimiterRange.location += delta

		subnodes = subnodes.map {
			var node = $0
			node.offset(delta)
			return node
		}
	}
}

extension Emphasis: SpanNodeParseable {
	static let regularExpression = (try? NSRegularExpression(pattern: "(?:\\s|^|[^\\w])(\\*|_)(?=\\S)(.+?)(?<=\\S)(\\1)", options: []))!

	init?(match: NSTextCheckingResult) {
		if match.numberOfRanges != 4 {
			return nil
		}

		leadingDelimiterRange = match.range(at: 1)
		textRange = match.range(at: 2)
		trailingDelimiterRange = match.range(at: 3)
	}
}

extension Emphasis: SpanNodeContainer {}

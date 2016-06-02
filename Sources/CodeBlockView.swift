//
//  CodeBlockView.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import CanvasNative
import X

final class CodeBlockView: ViewType, Annotation {

	// MARK: - Properties

	static let lineNumberWidth: CGFloat = 40

	var block: Annotatable

	var theme: Theme {
		didSet {
			backgroundColor = theme.codeBackground
			tintColor = theme.tintColor
			setNeedsDisplay()
		}
	}

	var horizontalSizeClass: UserInterfaceSizeClass = .Unspecified

	let placement = AnnotationPlacement.ExpandedBackground

	private let textLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .Right
		return label
	}()

	
	// MARK: - Initializers

	init?(block: Annotatable, theme: Theme) {
		guard let codeBlock = block as? CodeBlock else { return nil }
		self.block = codeBlock
		self.theme = theme

		super.init(frame: .zero)

		userInteractionEnabled = false
		contentMode = .Redraw
		backgroundColor = theme.backgroundColor

		textLabel.font = theme.monospaceFontOfSize(theme.fontSize)
		textLabel.text = codeBlock.lineNumber.description
		textLabel.textColor = Color(red: 0.847, green: 0.847, blue: 0.864, alpha: 1)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func drawRect(rect: CGRect) {
		guard let codeBlock = block as? CodeBlock, context = UIGraphicsGetCurrentContext() else { return }

		if traitCollection.horizontalSizeClass != .Regular {
			return
		}

		let path: CGPath?

		switch codeBlock.position {
		case .Single:
			path = UIBezierPath(roundedRect: bounds, cornerRadius: 4).CGPath
		case .Top:
			path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSize(width: 4, height: 4)).CGPath
		case .Bottom(_):
			path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: CGSize(width: 4, height: 4)).CGPath
		default:
			path = nil
		}

		if let path = path {
			CGContextAddPath(context, path)
			CGContextClip(context)
		}

		CGContextSetFillColorWithColor(context, theme.codeBackground.CGColor)
		CGContextFillRect(context, bounds)

		CGContextSetFillColorWithColor(context, Color(red: 0.937, green: 0.937, blue: 0.946,alpha: 1).CGColor)
		CGContextFillRect(context, CGRect(x: 0, y: 0, width: self.dynamicType.lineNumberWidth, height: bounds.height))
	}

	override func traitCollectionDidChange(previousTraitOrganization: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitOrganization)

		guard let codeBlock = block as? CodeBlock else { return }

		if traitCollection.horizontalSizeClass != .Regular {
			backgroundColor = theme.codeBackground
			textLabel.removeFromSuperview()
			return
		}

		backgroundColor = theme.backgroundColor

		if textLabel.superview == nil {
			addSubview(textLabel)

			// TODO: This is terrible
			let top: CGFloat = codeBlock.position.isTop ? 17 : 1

			NSLayoutConstraint.activateConstraints([
				textLabel.trailingAnchor.constraintEqualToAnchor(leadingAnchor, constant: self.dynamicType.lineNumberWidth - 6),
				textLabel.topAnchor.constraintEqualToAnchor(topAnchor, constant: top)
			])
		}

		setNeedsDisplay()
	}
}

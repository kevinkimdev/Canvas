//
//  CanvasCell.swift
//  Canvas
//
//  Created by Sam Soffes on 11/18/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasKit

final class CanvasCell: UITableViewCell {

	// MARK: - Properties

	let iconView: UIImageView = {
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .Center
		view.tintColor = .whiteColor()
		return view
	}()

	let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = Color.white
		label.textColor = Color.black
		label.highlightedTextColor = Color.white
		label.font = Font.sansSerif(weight: .Bold)
		label.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
		return label
	}()

	let summaryLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = Color.white
		label.textColor = Color.darkGray
		label.highlightedTextColor = Color.white
		return label
	}()

	let timeLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = Color.white
		label.textColor = Color.gray
		label.highlightedTextColor = Color.white
		label.font = Font.sansSerif(size: .Small)
		label.textAlignment = .Right
		return label
	}()

	let disclosureIndicatorView = UIImageView(image: UIImage(named: "Chevron"))

	private var canvas: Canvas? {
		didSet {
			updateHighlighted()

			guard let canvas = canvas else {
				timeLabel.text = nil
				return
			}

			if canvas.archivedAt == nil {
				titleLabel.textColor = Color.black
				summaryLabel.textColor = Color.darkGray
			} else {
				titleLabel.textColor = Color.gray
				summaryLabel.textColor = Color.gray
				iconView.image = iconView.image?.imageWithRenderingMode(.AlwaysTemplate)
			}

			timeLabel.text = canvas.updatedAt.briefTimeAgoInWords
		}
	}
	

	// MARK: - Initializers

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)

		let view = UIView()
		view.backgroundColor = tintColor
		selectedBackgroundView = view

		accessoryView = disclosureIndicatorView

		contentView.addSubview(iconView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(summaryLabel)
		contentView.addSubview(timeLabel)

		let verticalSpacing: CGFloat = 2

		NSLayoutConstraint.activateConstraints([
			NSLayoutConstraint(item: iconView, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .LeadingMargin, multiplier: 1, constant: 0),
			iconView.widthAnchor.constraintEqualToConstant(28),
			iconView.heightAnchor.constraintEqualToConstant(28),
			iconView.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor),

			titleLabel.bottomAnchor.constraintEqualToAnchor(contentView.centerYAnchor, constant: -verticalSpacing),
			titleLabel.leadingAnchor.constraintEqualToAnchor(iconView.trailingAnchor, constant: 8),
			titleLabel.trailingAnchor.constraintLessThanOrEqualToAnchor(timeLabel.leadingAnchor),

			summaryLabel.topAnchor.constraintEqualToAnchor(contentView.centerYAnchor, constant: verticalSpacing),
			summaryLabel.leadingAnchor.constraintEqualToAnchor(titleLabel.leadingAnchor),
			summaryLabel.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor, constant: -8),

			NSLayoutConstraint(item: timeLabel, attribute: .Baseline, relatedBy: .Equal, toItem: titleLabel, attribute: .Baseline, multiplier: 1, constant: 0),
			timeLabel.trailingAnchor.constraintEqualToAnchor(summaryLabel.trailingAnchor),
			timeLabel.widthAnchor.constraintLessThanOrEqualToConstant(100)
		])
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func tintColorDidChange() {
		super.tintColorDidChange()
		selectedBackgroundView?.backgroundColor = tintColor
	}
	

	// MARK: - UITableViewCell

	override func setHighlighted(highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		updateHighlighted()
	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		updateHighlighted()
	}


	// MARK: - Private

	private func updateHighlighted() {
		if highlighted || selected {
			disclosureIndicatorView.tintColor = .whiteColor()
			iconView.tintColor = .whiteColor()
		} else {
			disclosureIndicatorView.tintColor = canvas?.archivedAt == nil ? Color.disclosureIndicator : Color.gray
			iconView.tintColor = Color.gray
		}
	}
}


extension CanvasCell: CellType {
	func configure(row row: Row) {
		titleLabel.text = row.text

		if let summary = row.detailText where summary.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
			summaryLabel.text = summary
			summaryLabel.font = Font.sansSerif(size: .Subtitle)
			iconView.image = UIImage(named: "Document")?.imageWithRenderingMode(.AlwaysOriginal)
			iconView.highlightedImage = UIImage(named: "Document")?.imageWithRenderingMode(.AlwaysTemplate)
		} else {
			summaryLabel.text = "No Content"
			summaryLabel.font = Font.sansSerif(size: .Subtitle, style: .Italic)
			iconView.image = UIImage(named: "Document-Blank")?.imageWithRenderingMode(.AlwaysOriginal)
			iconView.highlightedImage = UIImage(named: "Document-Blank")?.imageWithRenderingMode(.AlwaysTemplate)
		}

		canvas = row.context?["canvas"] as? Canvas
	}
}

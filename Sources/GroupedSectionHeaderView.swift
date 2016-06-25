//
//  GroupedSectionHeaderView.swift
//  Canvas
//
//  Created by Sam Soffes on 6/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

final class GroupedSectionHeaderView: SectionHeaderView {

	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = Swatch.groupedTableBackground
		tintColor = Swatch.gray
		
		textLabel.font = Font.sansSerif(size: .small)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func tintColorDidChange() {
		super.tintColorDidChange()
		textLabel.textColor = tintColor
	}
}

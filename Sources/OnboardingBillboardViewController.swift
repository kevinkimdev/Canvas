//
//  OnboardingViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 7/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasText

class OnboardingBillboardViewController: StackViewController {
	
	// MARK: - UIViewController

	let illustrationView: UIImageView = {
		let view = UIImageView()
		view.contentMode = .Center
		return view
	}()
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = Swatch.black
		label.numberOfLines = 0
		label.textAlignment = .Center
		return label
	}()
	
	let subtitleLabel: UILabel = {
		let label = UILabel()
		label.textColor = Swatch.gray
		label.numberOfLines = 0
		label.textAlignment = .Center
		return label
	}()
	
	private var textIllustrationSpacing: NSLayoutConstraint!
	
	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		stackView.axis = .Vertical
		stackView.alignment = .Center
		stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16 + 44, right: 16)
		stackView.layoutMarginsRelativeArrangement = true
		
		stackView.addArrangedSubview(titleLabel)
		stackView.addSpace(12)
		stackView.addArrangedSubview(subtitleLabel)
		
		let spacer = UIView()
		spacer.translatesAutoresizingMaskIntoConstraints = false
		stackView.addArrangedSubview(spacer)
		
		textIllustrationSpacing = spacer.heightAnchor.constraintEqualToConstant(0)
		textIllustrationSpacing.active = true
		
		stackView.addArrangedSubview(illustrationView)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateFonts), name: UIContentSizeCategoryDidChangeNotification, object: nil)
		updateFonts()
	}
	
	override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		textIllustrationSpacing.constant = traitCollection.horizontalSizeClass == .Regular ? 48 : 32
	}
	
	
	// MARK: - Private
	
	@objc private func updateFonts() {
		titleLabel.font = TextStyle.title1.font()
		subtitleLabel.font = TextStyle.body.font()
	}
}

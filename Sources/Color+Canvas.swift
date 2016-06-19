//
//  Color+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 1/25/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit

extension CanvasKit.Color {
	var uiColor: UIColor {
		return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
	}
}

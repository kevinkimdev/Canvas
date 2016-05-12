//
//  UIViewController+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 5/11/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

extension UIViewController {
	func dismissDetailViewController(sender: AnyObject?) {
		if let splitViewController = splitViewController where !splitViewController.collapsed {
			splitViewController.dismissDetailViewController(sender)
			return
		}

		if let presenter = targetViewControllerForAction(#selector(dismissDetailViewController), sender: sender) {
			presenter.dismissDetailViewController(self)
		}
	}
}


extension UINavigationController {
	override func dismissDetailViewController(sender: AnyObject?) {
		// Hack to fix nested navigation controllers that split view makes. Ugh.
		if viewControllers.count == 1 {
			navigationController?.popViewControllerAnimated(true)
			return
		}
		popViewControllerAnimated(true)
	}
}


extension UISplitViewController {
	override func dismissDetailViewController(sender: AnyObject?) {
		showDetailViewController(NavigationController(rootViewController: PlaceholderViewController()), sender: sender)
	}
}

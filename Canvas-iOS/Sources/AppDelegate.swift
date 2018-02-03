//
//  AppDelegate.swift
//  Canvas
//
//  Created by Sam Soffes on 11/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

@UIApplicationMain final class AppDelegate: UIResponder {

	// MARK: - Properties

	var window: UIWindow?
	let rootViewController = RootViewController()


	// MARK: - Private
	
//	private func open(canvasURL: NSURL) -> Bool {
//		// For now require an account
//		guard let splitViewController = (window?.rootViewController as? RootViewController)?.viewController as? SplitViewController else { return false }
//
//		let viewController = NavigationController(rootViewController: LoadCanvasViewController(account: account, canvasID: canvasID))
//
//		let show = {
//			splitViewController.presentViewController(viewController, animated: true, completion: nil)
//		}
//
//		if splitViewController.presentedViewController != nil {
//			splitViewController.presentedViewController?.dismissViewControllerAnimated(false, completion: show)
//		} else {
//			show()
//		}
//
//		return true
//	}
}


extension AppDelegate: UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		// Appearance
		UIImageView.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = Swatch.darkGray

		// Defaults
		DispatchQueue.main.async {
			UserDefaults.standard.register(defaults: [
				SleepPrevention.defaultsKey: SleepPrevention.whilePluggedIn.rawValue
			])

			if let info = Bundle.main.infoDictionary, let version = info["CFBundleVersion"] as? String, let shortVersion = info["CFBundleShortVersionString"] as? String {
				UserDefaults.standard.set("\(shortVersion) (\(version))", forKey: "HumanReadableVersion")
				UserDefaults.standard.synchronize()
			}
		}

		// Shortcut items
		application.shortcutItems = [
			UIApplicationShortcutItem(type: "shortcut-new", localizedTitle: LocalizedString.newCanvasCommand.string, localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "New Canvas Shortcut"), userInfo: nil)
		]

		window?.rootViewController = rootViewController
		
		return true
	}

//	func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
//		showPersonalNotes() { viewController in
//			guard let viewController = viewController else {
//				completionHandler(false)
//				return
//			}
//
//			if shortcutItem.type == "shortcut-new" {
//				viewController.ready = {
//					viewController.createCanvas()
//				}
//			} else if shortcutItem.type == "shortcut-search" {
//				viewController.ready = {
//					viewController.search()
//				}
//			}
//
//			completionHandler(true)
//		}
//	}
//
//	func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([Any]?) -> Void) -> Bool {
//		guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else { return false }
//
//		// Open canvas
//		if open(canvasURL: url) {
//			return true
//		}
//
//		// Verify account
//		if let components = url.pathComponents, components.count == 2 && components[1] == "verify" {
//			return verifyAccount(url: url)
//		}
//
//		// Fallback
//		application.openURL(url)
//		return false
//	}
}

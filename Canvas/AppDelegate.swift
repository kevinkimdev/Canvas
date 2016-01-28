//
//  AppDelegate.swift
//  Canvas
//
//  Created by Sam Soffes on 11/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

#if !DEBUG
	import Raven
#endif

private let sentryDSN = "https://790a7fad533f47eaa666a99820de5d04:db580e425bd54c39bf649f3551408901@app.getsentry.com/65177"

@UIApplicationMain final class AppDelegate: UIResponder {

	// MARK: - Properties

	var window: UIWindow?


	// MARK: - Private

	private func showPersonalNotes(completion: OrganizationCanvasesViewController? -> Void) {
		guard let rootViewController = window?.rootViewController as? RootViewController,
			navigationController = rootViewController.viewController as? UINavigationController
		else {
			completion(nil)
			return
		}

		navigationController.popToRootViewControllerAnimated(false)

		guard let organizations = navigationController.topViewController as? OrganizationsViewController else {
			completion(nil)
			return
		}

		organizations.showPersonalNotes() {
			completion(navigationController.topViewController as? OrganizationCanvasesViewController)
		}
	}
}


extension AppDelegate: UIApplicationDelegate {
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		#if !DEBUG
			RavenClient.clientWithDSN(sentryDSN)
			RavenClient.sharedClient?.setupExceptionHandler()
		#endif

		// Analytics
		Analytics.track(.LaunchedApp)

		dispatch_async(dispatch_get_main_queue()) {
			if let info = NSBundle.mainBundle().infoDictionary, version = info["CFBundleVersion"] as? String, shortVersion = info["CFBundleShortVersionString"] as? String {
				NSUserDefaults.standardUserDefaults().setObject("\(shortVersion) (\(version))", forKey: "HumanReadableVersion")
				NSUserDefaults.standardUserDefaults().synchronize()
			}
		}

		application.shortcutItems = [
			UIApplicationShortcutItem(type: "shortcut-new", localizedTitle: "New Canvas", localizedSubtitle: "In Personal", icon: UIApplicationShortcutIcon(templateImageName: "New Canvas Shortcut"), userInfo: nil),
			UIApplicationShortcutItem(type: "shortcut-search", localizedTitle: "Search", localizedSubtitle: "In Personal", icon: UIApplicationShortcutIcon(type: .Search), userInfo: nil)
		]

		return true
	}

	func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
		showPersonalNotes() { viewController in
			guard let viewController = viewController else {
				completionHandler(false)
				return
			}

			if shortcutItem.type == "shortcut-new" {
				viewController.ready = {
					viewController.createCanvas()
				}
			} else if shortcutItem.type == "shortcut-search" {
				viewController.ready = {
					viewController.search()
				}
			}

			completionHandler(true)
		}
	}
}
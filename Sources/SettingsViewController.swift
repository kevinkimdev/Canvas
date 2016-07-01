//
//  SettingsViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 6/28/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit
import Static

final class SettingsViewController: TableViewController, Accountable {

	// MARK: - Properties

	var account: Account


	// MARK: - Initializers

	init(account: Account) {
		self.account = account
		super.init(style: .Grouped)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Settings"

		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close"), style: .Plain, target: self, action: #selector(close))
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

		dataSource.automaticallyDeselectRows = false
		reload()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reload), name: NSUserDefaultsDidChangeNotification, object: nil)
	}


	// MARK: - Private

	@objc private func reload() {
		let version = NSUserDefaults.standardUserDefaults().stringForKey("HumanReadableVersion")
		let footer = version.flatMap { Section.Extremity.Title("Version \($0)") }

		dataSource.sections = [
			Section(header: "Account", rows: [
				Row(text: "Username", detailText: account.user.username, image: UIImage(named: "Username")),
				Row(text: "Account Details…", accessory: .DisclosureIndicator, selection: showAccount, image: UIImage(named: "User"))
			]),
			Section(header: "Editor", rows: [
				Row(text: "Prevent Sleep", detailText: SleepPrevention.currentPreference.description, accessory: .DisclosureIndicator, selection: showSleepPicker, image: UIImage(named: "Moon")),
			]),
			Section(rows: [
				Row(text: "Help", cellClass: ButtonCell.self, selection: contactSupport, image: UIImage(named: "Help"))
			], footer: footer),
			Section(rows: [
				Row(text: "Log Out", cellClass: ButtonCell.self, selection: logOut, image: UIImage(named: "SignOut"))
			])
		]
	}


	// MARK: - Actions

	@objc private func close() {
		dismissViewControllerAnimated(true, completion: nil)
	}

	private func showAccount() {
		if let indexPath = tableView.indexPathForSelectedRow {
			tableView.deselectRowAtIndexPath(indexPath, animated: true)
		}

		guard let url = NSURL(string: "https://usecanvas.com/account") else { return }
		UIApplication.sharedApplication().openURL(url)
	}

	private func showSleepPicker() {
		let viewController = SleepPickerViewController()
		navigationController?.pushViewController(viewController, animated: true)
	}

	private func logOut() {
		AccountController.sharedController.currentAccount = nil
	}

	private func contactSupport() {
		guard let url = NSURL(string: "https://usecanvas.com/support") else { return }
		UIApplication.sharedApplication().openURL(url)
	}
}
